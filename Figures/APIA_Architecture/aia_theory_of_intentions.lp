% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"

%%%% Domains %%%%

% goal(Goal)
% activity(Activity)

%%%% Statics %%%%

% TODO: Are these supposed to be statics or fluents?
% TODO: Check holds(MinorGoal, Timestep)

% component(Activity, ComponentIndex, Component)
% length(Activity, ActivityLength)
% goal(Activity, ActivityGoal)

%%%% Fluents %%%%

fluent(inertial, active_goal(Goal)) :-
    goal(Goal).

fluent(inertial, status(Activity, ActivityIndex)) :-
    length(Activity, ActivityLength),
    ActivityIndex = -1..ActivityLength.

fluent(defined, active(Activity)) :-
    activity(Activity).

fluent(defined, child(ChildActivity, Activity)) :-
    activity(Activity),
    activity(ChildActivity),
    ChildActivity != Activity.

fluent(defined, child_goal(ChildGoal, Goal)) :-
    goal(Goal),
    goal(ChildGoal),
    ChildGoal != Goal.

fluent(defined, descendant(ChildActivity, Activity)) :-
    activity(Activity),
    activity(ChildActivity),
    ChildActivity != Activity.

fluent(defined, minor(Activity)) :-
    activity(Activity).

fluent(defined, minor(Goal)) :-
    goal(Goal).

fluent(defined, in_progress(Activity)) :-
    activity(Activity).

fluent(defined, in_progress(Goal)) :-
    goal(Goal).

fluent(defined, next_action(Activity, Action)) :-
    activity(Activity),
    action(Action).

fluent(inertial, next_name(Activity)) :-
    activity(Activity).

%%%% Actions %%%%

mental_agent_action(Action) :-
    activity(Activity),
    Action = (start(Activity); stop(Activity)).

% physical_agent_action(Action).

mental_exogenous_action(Action) :-
    goal(Goal),
    Action = (select(Goal); abandon(Goal)).

% physical_exogenous_action(Action)

action(Action) :-
    mental_agent_action(Action).

action(Action) :-
    physical_agent_action(Action).

action(Action) :-
    mental_exogenous_action(Action).

action(Action) :-
    physical_exogenous_action(Action).

action(wait).

%%%% Action descriptions %%%%

% -status(Activity, OldActivityIndex) if
%   status(Activity, ActivityIndex), OldActivityIndex != ActivityIndex
-holds(status(Activity, OldActivityIndex), Timestep) :-
    step(Timestep),
    holds(status(Activity, ActivityIndex), Timestep),
    length(Activity, ActivityLength),
    OldActivityIndex = -1..ActivityLength,
    OldActivityIndex != ActivityIndex.

% active(Activity) if
%   -status(Activity, -1)
holds(active(Activity), Timestep) :-
    step(Timestep),
    -holds(status(Activity, -1), Timestep).

% start(Activity) causes status(Activity, 0)
holds(status(Activity, 0), Timestep + 1) :-
    step(Timestep),
    occurs(start(Activity), Timestep).

% stop(Activity) causes status(Activity, -1)
holds(status(Activity, -1), Timestep + 1) :-
    step(Timestep),
    occurs(stop(Activity), Timestep).

% impossible start(Activity) if
%   active(Activity)
-occurs(start(Activity), Timestep) :-
    step(Timestep),
    holds(active(Activity), Timestep).

% impossible stop(Activity) if
%   -active(Activity)
-occurs(stop(Activity), Timestep) :-
    step(Timestep),
    -holds(active(Activity), Timestep).

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible Action1, Action2 if
%   physical_agent_action(Action1), mental_agent_action(Action2)
-occurs(Action1, Timestep) | -occurs(Action2, Timestep) :-
    step(Timestep),
    physical_agent_action(Action1),
    mental_agent_action(Action2).

% impossible Action1, Action2 if
%   mental_agent_action(Action1), mental_agent_action(Action2),
%   Action1 != Action2.
-occurs(Action1, Timestep) | -occurs(Action2, Timestep) :-
    step(Timestep),
    mental_agent_action(Action1),
    mental_agent_action(Action2),
    Action1 != Action2.

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, Action if
%   physical_agent_action(Action).
-occurs(wait, Timestep) | -occurs(Action, Timestep) :-
    step(Timestep),
    physical_agent_action(Action).

% impossible wait, Action if
%   mental_agent_action(Action).
-occurs(wait, Timestep) | -occurs(Action, Timestep) :-
    step(Timestep),
    mental_agent_action(Action).

% child(ChildActivity) if
%   component(Activity, Activity + 1, ChildActivity), status(Activity, ActivityIndex)
holds(child(ChildActivity), Timestep) :-
    step(Timestep),
    holds(component(Activity, Activity + 1, ChildActivity), Timestep),
    holds(status(Activity, ActivityIndex), Timestep).

% child_goal(ChildGoal, Goal) if
%   child(ChildActivity, Activity), goal(Activity, Goal), goal(ChildActivity, ChildGoal)
holds(child_goal(ChildGoal, Goal), Timestep) :-
    step(Timestep),
    holds(child(ChildActivity, Activity), Timestep),
    holds(goal(Activity, Goal), Timestep),
    holds(goal(ChildActivity, ChildGoal), Timestep).

% descendant(ChildActivity, Activity) if
%   child(ChildActivity, Activity)
holds(descendant(ChildActivity, Activity), Timestep) :-
    step(Timestep),
    holds(child(ChildActivity, Activity), Timestep).

% descendant(GrandChildActivity, Activity) if
%   descendant(ChildActivity, Activity), descendant(GrandChildActivity, ChildActivity)
holds(descendant(GrandChildActivity, Activity), Timestep) :-
    step(Timestep),
    holds(descendant(ChildActivity, Activity), Timestep),
    holds(descendant(GrandChildActivity, ChildActivity), Timestep).

% minor(ChildActivity) if
%   child(ChildActivity, Activity)
holds(minor(ChildActivity), Timestep) :-
    step(Timestep),
    holds(child(ChildActivity, Activity), Timestep).

% minor(ChildGoal) if
%   child_goal(ChildGoal, Goal)
holds(minor(ChildGoal), Timestep) :-
    step(Timestep),
    holds(child_goal(ChildGoal, Goal), Timestep).

% select(Goal) causes active_goal(Goal)
holds(active_goal(Goal), Timestep + 1) :-
    step(Timestep),
    occurs(select(Goal), Timestep).

% impossible select(Goal) if
%   active_goal(Goal)
-occurs(select(Goal), Timestep) :-
    step(Timestep),
    holds(active_goal(Goal), Timestep).

% abandon(Goal) causes -active_goal(Goal)
-holds(active_goal(Goal), Timestep + 1) :-
    step(Timestep),
    occurs(abandon(Goal), Timestep).

% impossible abandon(Goal) if
%   -active_goal(Goal)
-occurs(abandon(Goal), Timestep) :-
    -holds(active_goal(Goal), Timestep).

% impossible abandon(Goal) if
%   minor(Goal)
-occurs(abandon(Goal), Timestep) :-
    -holds(minor(Goal), Timestep).

% "We assume that no physical exogenous action may occur concurrently with a speical exogenous action"
% impossible Action1, Action2 if
%   mental_exogenous_action(Action1), physical_exogenous_action(Action2)
-occurs(Action1, Timestep) | -occurs(Action2, Timestep) :-
    step(Timestep),
    mental_exogenous_action(Action1),
    physical_exogenous_action(Action2).

% impossible Action1, Action2 if
%   mental_exogenous_action(Action1), physical_agent_action(Action2)
-occurs(Action1, Timestep) | -occurs(Action2, Timestep) :-
    step(Timestep),
    mental_exogenous_action(Action1),
    physical_agent_action(Action2).

% impossible Action1, Action2 if
%   mental_exogenous_action(Action1), mental_agent_action(Action2)
-occurs(Action1, Timestep) | -occurs(Action2, Timestep) :-
    step(Timestep),
    mental_exogenous_action(Action1),
    mental_agent_action(Action2).

% -active_goal(Goal) if
%   -minor(Goal), goal(Goal)
-holds(active_goal(Goal), Timestep) :-
    step(Timestep),
    -holds(minor(Goal), Timestep),
    holds(goal(Goal), Timestep).

%--- Sub goal ---%

% "An unachieved minor goal MinorGoal of an activity ChildActivity becomes active when ChildActivity is the next component of an ongoing activity Activity"
% active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), goal(ChildActivity, MinorGoal),
%   -MinorGoal, status(ChildActivity, -1)
holds(active_goal(MinorGoal), Timestep) :-
    step(Timestep),
    holds(minor(MinorGoal), Timestep),
    holds(child_goal(MinorGoal, Goal), Timestep),
    holds(active_goal(Goal), Timestep),
    holds(goal(ChildActivity, MinorGoal), Timestep),
    -holds(MinorGoal, Timestep),
    holds(status(ChildActivity, -1), Timestep).

% "A minor goal MinorGoal is no longer active when it is achieved."
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), MinorGoal.
-holds(active_goal(MinorGoal), Timestep) :-
    step(Timestep),
    holds(minor(MinorGoal), Timestep),
    holds(child_goal(MinorGoal, Goal), Timestep),
    holds(active_goal(Goal), Timestep),
    holds(MinorGoal, Timestep).

% "A minor goal MinorGoal is no longer active when its parent [goal] is no longer active"
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal), -active_goal(Goal)
-holds(active_goal(MinorGoal), Timestep) :-
    step(Timestep),
    holds(minor(MinorGoal), Timestep),
    holds(child_goal(MinorGoal, Goal), Timestep),
    -holds(active_goal(Goal), Timestep).

% "A minor goal MinorGoal of ChildActivity is no longer active when ChildActivity has been executed."
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), -MinorGoal,
%   goal(ChildActivity, MinorGoal), status(ChildActivity, ChildActivityIndex),
%   length(ChildActivity, ChildActivityLength)
-holds(active_goal(MinorGoal), Timestep) :-
    step(Timestep),
    holds(minor(MinorGoal), Timestep),
    holds(child_goal(MinorGoal, Goal), Timestep),
    holds(active_goal(Goal), Timestep),
    -holds(MinorGoal, Timestep),
    holds(goal(ChildActivity, MinorGoal), Timestep),
    holds(status(ChildActivity, ChildActivityIndex), Timestep),
    holds(length(ChildActivity, ChildActivityLength), Timestep),
    ChildActivityIndex = ChildActivityLength.

%--- Misc. ---%

% in_progress(Activity) if
%   active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Activity), Timestep) :-
    step(Timestep),
    holds(active(Activity), Timestep),
    holds(goal(Activity, Goal), Timestep),
    holds(active_goal(Goal), Timestep).

% in_progress(Goal) if
%   active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Goal), Timestep) :-
    step(Timestep),
    holds(active(Activity), Timestep),
    holds(goal(Activity, Goal), Timestep),
    holds(active_goal(Goal), Timestep).

% next_action(Activity, Action) if
%   physical_agent_action(Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), in_progress(Activity)
holds(next_action(Activity, Action), Timestep) :-
    step(Timestep),
    physical_agent_action(Action),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, Action), Timestep),
    holds(in_progress(Activity), Timestep).

% next_action(Activity, start(ChildActivity)) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), -active(ChildActivity)
holds(next_action(Activity, start(ChildActivity)), Timestep) :-
    step(Timestep),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), Timestep),
    holds(in_progress(Activity), Timestep),
    -holds(active(ChildActivity), Timestep).

% next_action(Activity, Action) if
%   physical_agent_action(Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), in_progress(ChildActivity), next_action(ChildActivity, Action)
holds(next_action(Activity, Action), Timestep) :-
    step(Timestep),
    physical_agent_action(Action),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), Timestep),
    holds(in_progress(Activity), Timestep),
    holds(in_progress(ChildActivity), Timestep),
    holds(next_action(ChildActivity, Action), Timestep).

% next_action(Activity, stop(ChildActivity)) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), active(ChildActivity),
%   goal(ChildActivity, ChildGoal), -active_goal(ChildGoal)
holds(next_action(Activity, stop(ChildActivity)), Timestep) :-
    step(Timestep),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), Timestep),
    holds(in_progress(Activity), Timestep),
    holds(active(ChildActivity), Timestep),
    holds(goal(ChildActivity, ChildGoal), Timestep),
    -holds(active_goal(ChildGoal), Timestep).

% Action causes status(Activity, ActivityIndex + 1) if
%   next_action(Activity, Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), physical_agent_action(Action)
holds(status(Activity, ActivityIndex + 1), Timestep + 1) :-
    step(Timestep),
    occurs(Action, Timestep),
    holds(next_action(Activity, Action), Timestep),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, Action), Timestep),
    physical_agent_action(Action).

% stop(ChildActivity) causes status(Activity, ActivityIndex + 1) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   next_action(Activity, stop(ChildActivity))
holds(status(Activity, ActivityIndex + 1), Timestep + 1) :-
    step(Timestep),
    occurs(stop(ChildActivity), Timestep),
    holds(status(Activity, ActivityIndex), Timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), Timestep),
    holds(next_action(Activity, stop(ChildActivity)), Timestep).

% stop(Activity) causes status(ChildActivity, -1) if
%   descendant(ChildActivity, Activity)
holds(status(ChildActivity, -1), Timestep + 1) :-
    step(Timestep),
    occurs(stop(Activity), Timestep),
    holds(descendant(ChildActivity, Activity), Timestep).

% -next_name(Activity) if
%   next_name(ChildActivity), Activity != ChildActivity
-holds(next_name(Activity), Timestep) :-
    step(Timestep),
    next_name(ChildActivity),
    activity(Activity),
    Activity != ChildActivity.

% start(Activity) causes next_name(Activity + 1) if
%   next_name(Activity), -minor(Activity)
holds(next_name(Activity + 1), Timestep + 1) :-
    step(Timestep),
    occurs(start(Activity), Timestep),
    holds(next_name(Activity), Timestep),
    -holds(minor(Activity), Timestep).
