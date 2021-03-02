% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
#program base.

#const activity_index__non_active = -1.
#const activity_index__new = 0.

%%%% Domains %%%%

% goal(Goal)
% activity(Activity)

%%%% Statics %%%%

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

% TODO: Verify that this is correct (our addition).
fluent(inertial, next_name(Activity)) :-
    Activity = ir.

%%%% Actions %%%%

%--- Agent actions ---%

agent_action(Action) :-
    activity(Activity),
    Action = (start(Activity); stop(Activity)).

action(Action) :-
    agent_action(Action).

%--- Exogenous actions ---%

special_exogenous_action(Action) :-
    goal(Goal),
    Action = (select(Goal); abandon(Goal)).

exogenous_action(Action) :-
    special_exogenous_action(Action).

action(Action) :-
    exogenous_action(Action).

%--- Physical actions ---%

% physical_action(Action).

action(Action) :-
    physical_action(Action).

%--- Mental actions ---%

mental_action(Action) :-
    activity(Activity),
    Action = (start(Activity); stop(Activity)).

mental_action(Action) :-
    goal(Goal),
    Action = (select(Goal); abandon(Goal)).

action(Action) :-
    mental_action(Action).

%--- Misc. actions ---%

action(wait).

%%%% Action descriptions %%%%
#program action_description(timestep).

% -status(Activity, OldActivityIndex) if
%   status(Activity, ActivityIndex), OldActivityIndex != ActivityIndex
-holds(status(Activity, OldActivityIndex), timestep) :-
    holds(status(Activity, ActivityIndex), timestep),
    length(Activity, ActivityLength),
    OldActivityIndex = -1..ActivityLength,
    OldActivityIndex != ActivityIndex.

% active(Activity) if
%   -status(Activity, -1)
holds(active(Activity), timestep) :-
    -holds(status(Activity, activity_index__non_active), timestep).

% start(Activity) causes status(Activity, 0)
holds(status(Activity, activity_index__new), timestep + 1) :-
    occurs(start(Activity), timestep).

% stop(Activity) causes status(Activity, -1)
holds(status(Activity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep).

% impossible start(Activity) if
%   active(Activity)
-occurs(start(Activity), timestep) :-
    holds(active(Activity), timestep).

% impossible stop(Activity) if
%   -active(Activity)
-occurs(stop(Activity), timestep) :-
    -holds(active(Activity), timestep).

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible Action1, Action2 if
%   mental_action(Action1), agent_action(Action1),
%   agent_action(Action2),
%   Action1 != Action2.
-occurs(Action1, timestep) | -occurs(Action2, timestep) :-
    mental_action(Action1),
    agent_action(Action1),
    agent_action(Action2),
    Action1 != Action2.

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, Action if
%   agent_action(Action).
-occurs(wait, timestep) | -occurs(Action, timestep) :-
    agent_action(Action).

% child(ChildActivity) if
%   component(Activity, Activity + 1, ChildActivity), status(Activity, ActivityIndex)
holds(child(ChildActivity), timestep) :-
    holds(component(Activity, Activity + 1, ChildActivity), timestep),
    holds(status(Activity, ActivityIndex), timestep).

% child_goal(ChildGoal, Goal) if
%   child(ChildActivity, Activity), goal(Activity, Goal), goal(ChildActivity, ChildGoal)
holds(child_goal(ChildGoal, Goal), timestep) :-
    holds(child(ChildActivity, Activity), timestep),
    goal(Activity, Goal),
    goal(ChildActivity, ChildGoal).

% descendant(ChildActivity, Activity) if
%   child(ChildActivity, Activity)
holds(descendant(ChildActivity, Activity), timestep) :-
    holds(child(ChildActivity, Activity), timestep).

% descendant(GrandChildActivity, Activity) if
%   descendant(ChildActivity, Activity), descendant(GrandChildActivity, ChildActivity)
holds(descendant(GrandChildActivity, Activity), timestep) :-
    holds(descendant(ChildActivity, Activity), timestep),
    holds(descendant(GrandChildActivity, ChildActivity), timestep).

% minor(ChildActivity) if
%   child(ChildActivity, Activity)
holds(minor(ChildActivity), timestep) :-
    holds(child(ChildActivity, Activity), timestep).

% minor(ChildGoal) if
%   child_goal(ChildGoal, Goal)
holds(minor(ChildGoal), timestep) :-
    holds(child_goal(ChildGoal, Goal), timestep).

% select(Goal) causes active_goal(Goal)
holds(active_goal(Goal), timestep + 1) :-
    occurs(select(Goal), timestep).

% impossible select(Goal) if
%   active_goal(Goal)
-occurs(select(Goal), timestep) :-
    holds(active_goal(Goal), timestep).

% abandon(Goal) causes -active_goal(Goal)
-holds(active_goal(Goal), timestep + 1) :-
    occurs(abandon(Goal), timestep).

% impossible abandon(Goal) if
%   -active_goal(Goal)
-occurs(abandon(Goal), timestep) :-
    -holds(active_goal(Goal), timestep).

% impossible abandon(Goal) if
%   minor(Goal)
-occurs(abandon(Goal), timestep) :-
    holds(minor(Goal), timestep).

% "We assume that no physical action may occur concurrently with a special exogenous action"
% impossible Action1, Action2 if
%   mental_action(Action1), special_exogenous_action(Action1),
%   physical_action(Action2)
-occurs(Action1, timestep) | -occurs(Action2, timestep) :-
    mental_action(Action1),
    special_exogenous_action(Action1),
    physical_action(Action2).

% "We assume that no mental agent action may occur concurrently with a special exogenous action"
% impossible Action1, Action2 if
%   mental_action(Action1), special_exogenous_action(Action1),
%   mental_action(Action2), agent_action(Action2)
-occurs(Action1, timestep) | -occurs(Action2, timestep) :-
    mental_action(Action1),
    special_exogenous_action(Action1),
    mental_action(Action2),
    agent_action(Action2).

% -active_goal(Goal) if
%   -minor(Goal), Goal
-holds(active_goal(Goal), timestep) :-
    -holds(minor(Goal), timestep),
    holds(Goal, timestep).

%--- Sub goal ---%

% "An unachieved minor goal MinorGoal of an activity ChildActivity becomes active when ChildActivity is the next component of an ongoing activity Activity"
% active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), goal(ChildActivity, MinorGoal),
%   -MinorGoal, status(ChildActivity, -1)
holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    goal(ChildActivity, MinorGoal),
    -holds(MinorGoal, timestep),
    holds(status(ChildActivity, activity_index__non_active), timestep).

% "A minor goal MinorGoal is no longer active when it is achieved."
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), MinorGoal.
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    holds(MinorGoal, timestep).

% "A minor goal MinorGoal is no longer active when its parent [goal] is no longer active"
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal), -active_goal(Goal)
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    -holds(active_goal(Goal), timestep).

% "A minor goal MinorGoal of ChildActivity is no longer active when ChildActivity has been executed."
% -active_goal(MinorGoal) if
%   minor(MinorGoal), child_goal(MinorGoal, Goal),
%   active_goal(Goal), -MinorGoal,
%   goal(ChildActivity, MinorGoal), status(ChildActivity, ChildActivityIndex),
%   length(ChildActivity, ChildActivityLength)
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    -holds(MinorGoal, timestep),
    goal(ChildActivity, MinorGoal),
    holds(status(ChildActivity, ChildActivityIndex), timestep),
    holds(length(ChildActivity, ChildActivityLength), timestep),
    ChildActivityIndex = ChildActivityLength.

%--- Misc. ---%

% in_progress(Activity) if
%   active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Activity), timestep) :-
    holds(active(Activity), timestep),
    goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% in_progress(Goal) if
%   active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Goal), timestep) :-
    holds(active(Activity), timestep),
    goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% next_action(Activity, Action) if
%   physical_action(Action), agent_action(Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), in_progress(Activity)
holds(next_action(Activity, Action), timestep) :-
    physical_action(Action),
    agent_action(Action),
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, Action), timestep),
    holds(in_progress(Activity), timestep).

% next_action(Activity, start(ChildActivity)) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), -active(ChildActivity)
holds(next_action(Activity, start(ChildActivity)), timestep) :-
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), timestep),
    holds(in_progress(Activity), timestep),
    -holds(active(ChildActivity), timestep).

% next_action(Activity, Action) if
%   agent_action(Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), in_progress(ChildActivity), next_action(ChildActivity, Action)
holds(next_action(Activity, Action), timestep) :-
    agent_action(Action),
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), timestep),
    holds(in_progress(Activity), timestep),
    holds(in_progress(ChildActivity), timestep),
    holds(next_action(ChildActivity, Action), timestep).

% next_action(Activity, stop(ChildActivity)) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), active(ChildActivity),
%   goal(ChildActivity, ChildGoal), -active_goal(ChildGoal)
holds(next_action(Activity, stop(ChildActivity)), timestep) :-
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), timestep),
    holds(in_progress(Activity), timestep),
    holds(active(ChildActivity), timestep),
    goal(ChildActivity, ChildGoal),
    -holds(active_goal(ChildGoal), timestep).

% Action causes status(Activity, ActivityIndex + 1) if
%   next_action(Activity, Action), status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), physical_action(Action), agent_action(Action)
holds(status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(Action, timestep),
    holds(next_action(Activity, Action), timestep),
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, Action), timestep),
    physical_action(Action),
    agent_action(Action).

% stop(ChildActivity) causes status(Activity, ActivityIndex + 1) if
%   status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   next_action(Activity, stop(ChildActivity))
holds(status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(stop(ChildActivity), timestep),
    holds(status(Activity, ActivityIndex), timestep),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), timestep),
    holds(next_action(Activity, stop(ChildActivity)), timestep).

% stop(Activity) causes status(ChildActivity, -1) if
%   descendant(ChildActivity, Activity)
holds(status(ChildActivity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep),
    holds(descendant(ChildActivity, Activity), timestep).

% -next_name(Activity) if
%   next_name(ChildActivity), Activity != ChildActivity
-holds(next_name(Activity), timestep) :-
    next_name(ChildActivity),
    activity(Activity),
    Activity != ChildActivity.

% start(Activity) causes next_name(Activity + 1) if
%   next_name(Activity), -minor(Activity)
holds(next_name(Activity + 1), timestep + 1) :-
    occurs(start(Activity), timestep),
    holds(next_name(Activity), timestep),
    -holds(minor(Activity), timestep).
