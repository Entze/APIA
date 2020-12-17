% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"

% G = goal
% M = activity

fluent(inertial, active_goal(Goal)).
fluent(inertial, status(Activity, ActivityIndex)).
fluent(defined, active(Activity)).
fluent(defined, child(ChildActivity, Activity)).
fluent(defined, child_goal(ChildGoal, Goal)).
fluent(defined, descendant(ChildActivity, Activity)).
fluent(defined, minor(Activity)).
fluent(defined, minor(Goal)).
fluent(defined, in_progress(Activity)).
fluent(defined, in_progress(Goal)).
fluent(defined, next_act(Activity, Action))
fluent(inertial, next_name(Activity)).

mental_agent_action(Action) :-
    Action = (start(Activity); stop(Activity)).

physical_agent_action(Action)

special_exogenous_action(Action) :-
    % Exogenous
    Action = (select(Goal); abandon(Goal)).

%action(Action) :-
%    physical_action(Action).
%
%action(Action) :-
%    mental_action(Action).

action(wait).

% -status(Activity, OldActivityIndex) if status(Activity, ActivityIndex), OldActivityIndex != ActivityIndex
-holds(status(Activity, OldActivityIndex), I) :-
    step(I),
    holds(status(Activity, ActivityIndex), I),
    OldActivityIndex != ActivityIndex.

% active(Activity) if -status(Activity, -1)
holds(active(Activity), I) :-
    step(I),
    holds(status(Activity, -1), I).

% start(Activity) causes status(Activity, 0)
holds(start(Activity), I) :-
    step(I),
    holds(status(Activity, 0), I).

% stop(Activity) causes status(Activity, -1)
holds(stop(Activity), I) :-
    step(I),
    holds(status(Activity, -1), I).

% impossible start(Activity) if active(Activity)
-occurs(start(Activity), I) :-
    step(I),
    holds(active(Activity), I).

% impossible stop(Activity) if -active(Activity)
-occurs(stop(Activity), I) :-
    step(I),
    -holds(active(Activity), I).

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible Action1, Action2 if physical_agent_action(Action1), mental_agent_action(Action2)
-occurs(Action1, I) | -occurs(Action2, I) :-
    step(I),
    physical_agent_action(Action1),
    mental_agent_action(Action2).

% impossible Action1, Action2 if mental_agent_action(Action1), mental_agent_action(Action2), Action1 != Action2.
-occurs(Action1, I) | -occurs(Action2, I) :-
    step(I),
    mental_agent_action(Action1),
    mental_agent_action(Action2),
    Action1 != Action2.

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, Action if physical_agent_action(Action).
-occurs(wait, I) | -occurs(Action, I) :-
    step(I),
    physical_agent_action(Action).

% impossible wait, Action if mental_agent_action(Action).
-occurs(wait, I) | -occurs(Action, I) :-
    step(I),
    mental_agent_action(Action).

% child(ChildActivity) if component(Activity, Activity + 1, ChildActivity), status(Activity, ActivityIndex)
holds(child(ChildActivity), I) :-
    step(I),
    holds(component(Activity, Activity + 1, ChildActivity), I),
    holds(status(Activity, ActivityIndex), I).

% child_goal(ChildGoal, Goal) if child(ChildActivity, Activity), goal(Activity, Goal), goal(ChildActivity, ChildGoal)
holds(child_goal(ChildGoal, Goal), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I),
    holds(goal(Activity, Goal), I),
    holds(goal(ChildActivity, ChildGoal), I).

% descendant(ChildActivity, Activity) if child(ChildActivity, Activity)
holds(descendant(ChildActivity, Activity), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I).

% descendant(GrandChildActivity, Activity) if descendant(ChildActivity, Activity), descendant(GrandChildActivity, ChildActivity)
holds(descendant(GrandChildActivity, Activity), I) :-
    step(I),
    holds(descendant(ChildActivity, Activity), I),
    holds(descendant(GrandChildActivity, ChildActivity), I).

% minor(ChildActivity) if child(ChildActivity, Activity)
holds(minor(ChildActivity), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I).

% minor(ChildGoal) if child_goal(ChildGoal, Goal)
holds(minor(ChildGoal), I) :-
    step(I),
    holds(child_goal(ChildGoal, Goal), I).

% select(Goal) causes active_goal(Goal)
holds(active_goal(Goal), I + 1) :-
    step(I),
    occurs(select(Goal), I).

% impossible select(Goal) if active_goal(Goal)
-occurs(select(Goal), I) :-
    step(I),
    holds(active_goal(Goal), I).

% abandon(Goal) causes -active_goal(Goal)
-holds(active_goal(Goal), I + 1) :-
    step(I),
    occurs(abandon(Goal), I).

% impossible abandon(Goal) if -active_goal(Goal)
-occurs(abandon(Goal), I) :-
    -holds(active_goal(Goal), I).

% impossible abandon(Goal) if minor(Goal)
-occurs(abandon(Goal), I) :-
    -holds(minor(Goal), I).

% "We assume that no physical exogenous action may occur concurrently with a speical exogenous action"
% impossible Action1, Action2 if special_exogenous_action(Action1), physical_exogenous_action(Action2)
-occurs(Action1, I) | -occurs(Action2, I) :-
    step(I),
    special_exogenous_action(Action1),
    physical_exogenous_action(Action2).

% impossible Action1, Action2 if special_exogenous_action(Action1), physical_agent_action(Action2)
-occurs(Action1, I) | -occurs(Action2, I) :-
    step(I),
    special_exogenous_action(Action1),
    physical_agent_action(Action2).

% impossible Action1, Action2 if special_exogenous_action(Action1), mental_agent_action(Action2)
-occurs(Action1, I) | -occurs(Action2, I) :-
    step(I),
    special_exogenous_action(Action1),
    mental_agent_action(Action2).

% -active_goal(Goal) if -minor(Goal), goal(Goal)
-holds(active_goal(Goal), I) :-
    step(I),
    -holds(minor(Goal), I),
    holds(goal(Goal), I).

%%%% Sub goal %%%%

% "An unachieved minor goal MinorGoal of an activity ChildActivity becomes active when ChildActivity is the next component of an ongoing activity Activity"
% active_goal(MinorGoal) if minor(MinorGoal), child_goal(MinorGoal, Goal), active_goal(Goal), goal(ChildActivity, MinorGoal), -MinorGoal, status(ChildActivity, -1)
holds(active_goal(MinorGoal), I) :-
    step(I),
    holds(minor(MinorGoal), I),
    holds(child_goal(MinorGoal, Goal), I),
    holds(active_goal(Goal), I),
    holds(goal(ChildActivity, MinorGoal), I),
    -holds(MinorGoal, I),
    holds(status(ChildActivity, -1), I).

% "A minor goal MinorGoal is no longer active when it is achieved."
% -active_goal(MinorGoal) if minor(MinorGoal), child_goal(MinorGoal, Goal), active_goal(Goal), MinorGoal.
-holds(active_goal(MinorGoal), I) :-
    step(I),
    holds(minor(MinorGoal), I),
    holds(child_goal(MinorGoal, Goal), I),
    holds(active_goal(Goal), I),
    holds(MinorGoal, I).

% "A minor goal MinorGoal is no longer active when its parent [goal] is no longer active"
% -active_goal(MinorGoal) if minor(MinorGoal), child_goal(MinorGoal, Goal), -active_goal(Goal)
-holds(active_goal(MinorGoal), I) :-
    step(I),
    holds(minor(MinorGoal), I),
    holds(child_goal(MinorGoal, Goal), I),
    -holds(active_goal(Goal), I).

% "A minor goal MinorGoal of ChildActivity is no longer active when ChildActivity has been executed."
% -active_goal(MinorGoal) if minor(MinorGoal), child_goal(MinorGoal, Goal), active_goal(Goal), -MinorGoal, goal(ChildActivity, MinorGoal), status(ChildActivity, ChildActivityIndex), length(ChildActivity, ChildActivityIndex)
-holds(active_goal(MinorGoal), I) :-
    step(I),
    holds(minor(MinorGoal), I),
    holds(child_goal(MinorGoal, Goal), I),
    holds(active_goal(Goal), I),
    -holds(MinorGoal, I),
    holds(goal(ChildActivity, MinorGoal), I),
    holds(status(ChildActivity, ChildActivityIndex), I),
    holds(length(ChildActivity, ChildActivityIndex), I).

%%%% Misc. %%%%

% in_progress(Activity) if active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Activity), I) :-
    step(I),
    holds(active(Activity), I),
    holds(goal(Activity, Goal), I),
    holds(active_goal(Goal), I).

% in_progress(Goal) if active(Activity), goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Goal), I) :-
    step(I),
    holds(active(Activity), I),
    holds(goal(Activity, Goal), I),
    holds(active_goal(Goal), I).

% next_act(Activity, Action) if physical_agent_action(Action), status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, Action), in_progress(Activity)
holds(next_act(Activity, Action), I) :-
    step(I),
    physical_agent_action(Action),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, Action), I),
    holds(in_progress(Activity), I).

% next_act(Activity, start(ChildActivity)) if status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity), in_progress(Activity), -active(ChildActivity)
holds(next_act(Activity, start(ChildActivity)), I) :-
    step(I),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    -holds(active(ChildActivity), I).

% next_act(Activity, Action) if agent_action(Action), status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity), in_progress(Activity), in_progress(ChildActivity), next_act(ChildActivity, Action)
holds(next_act(Activity, Action), I) :-
    step(I),
    agent_action(Action),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    holds(in_progress(ChildActivity), I),
    holds(next_act(ChildActivity, Action), I).

% next_act(Activity, stop(ChildActivity)) if status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity), in_progress(Activity), active(ChildActivity), goal(ChildActivity, ChildGoal), -active_goal(ChildGoal)
holds(next_act(Activity, stop(ChildActivity)), I) :-
    step(I),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    holds(active(ChildActivity), I),
    holds(goal(ChildActivity, ChildGoal), I),
    -holds(active_goal(ChildGoal), I).

% Action causes status(Activity, ActivityIndex + 1) if next_act(Activity, Action), status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, Action), physical_agent_action(Action)
holds(status(Activity, ActivityIndex + 1), I + 1) :-
    step(I),
    occurs(Action, I),
    holds(next_act(Activity, Action), I),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, Action), I),
    physical_agent_action(Action).

% stop(ChildActivity) causes status(Activity, ActivityIndex + 1) if status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity), next_act(Activity, stop(ChildActivity))
holds(status(Activity, ActivityIndex + 1), I + 1) :-
    step(I),
    occurs(stop(ChildActivity), I),
    holds(status(Activity, ActivityIndex), I),
    holds(component(Activity, ActivityIndex + 1, ChildActivity), I),
    holds(next_act(Activity, stop(ChildActivity)), I).

% stop(Activity) causes status(ChildActivity, -1) if descendant(ChildActivity, Activity)
holds(status(ChildActivity, -1), I + 1) :-
    step(I),
    occurs(stop(Activity), I),
    holds(descendant(ChildActivity, Activity), I).

% -next_name(Activity) if next_name(ChildActivity), Activity != ChildActivity
-holds(next_name(Activity), I) :-
    step(I),
    next_name(ChildActivity),
    % TODO: Bind Activity
    Activity != ChildActivity.

% start(Activity) causes next_name(Activity + 1) if next_name(Activity), -minor(Activity)
holds(next_name(Activity + 1), I + 1) :-
    step(I),
    occurs(start(Activity), I),
    holds(next_name(Activity), I),
    -holds(minor(Activity), I).
