% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
#program base.

#const activity_index__non_active = -1.
#const activity_index__new = 0.

%%%% Domains %%%%

% goal(Goal)
% activity(Activity)

%%%% Statics %%%%

% activity_component(Activity, ComponentIndex, Component)
% activity_length(Activity, ActivityLength)
% activity_goal(Activity, ActivityGoal)

%%%% Fluents %%%%

fluent(inertial, active_goal(Goal)) :-
    goal(Goal).

% Originally: status(Activity, ActivityIndex)
fluent(inertial, activity_status(Activity, ActivityIndex)) :-
    activity_length(Activity, ActivityLength),
    ActivityIndex = -1..ActivityLength.

% Originally: active(Activity)
fluent(defined, active_activity(Activity)) :-
    activity(Activity).

% Originally: child(ChildActivity, Activity)
fluent(defined, child_activity(ChildActivity, Activity)) :-
    activity(Activity),
    activity(ChildActivity),
    ChildActivity != Activity.

fluent(defined, child_goal(ChildGoal, Goal)) :-
    goal(Goal),
    goal(ChildGoal),
    ChildGoal != Goal.

% Originally: descendant(ChildActivity, Activity)
fluent(defined, descendant_activity(ChildActivity, Activity)) :-
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

% -activity_status(Activity, OldActivityIndex) if
%   activity_status(Activity, ActivityIndex), OldActivityIndex != ActivityIndex
-holds(activity_status(Activity, OldActivityIndex), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_length(Activity, ActivityLength),
    OldActivityIndex = -1..ActivityLength,
    OldActivityIndex != ActivityIndex.

% active_activity(Activity) if
%   -activity_status(Activity, -1)
holds(active_activity(Activity), timestep) :-
    -holds(activity_status(Activity, activity_index__non_active), timestep).

% start(Activity) causes activity_status(Activity, 0)
holds(activity_status(Activity, activity_index__new), timestep + 1) :-
    occurs(start(Activity), timestep).

% stop(Activity) causes activity_status(Activity, -1)
holds(activity_status(Activity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep).

% impossible start(Activity) if
%   active_activity(Activity)
-occurs(start(Activity), timestep) :-
    holds(active_activity(Activity), timestep).

% impossible stop(Activity) if
%   -active_activity(Activity)
-occurs(stop(Activity), timestep) :-
    -holds(active_activity(Activity), timestep).

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

% child_activity(ChildActivity) if
%   component(Activity, Activity + 1, ChildActivity), activity_status(Activity, ActivityIndex)
holds(child_activity(ChildActivity), timestep) :-
    component(Activity, Activity + 1, ChildActivity),
    holds(activity_status(Activity, ActivityIndex), timestep).

% child_goal(ChildGoal, Goal) if
%   child_activity(ChildActivity, Activity), activity_goal(Activity, Goal), activity_goal(ChildActivity, ChildGoal)
holds(child_goal(ChildGoal, Goal), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep),
    activity_goal(Activity, Goal),
    activity_goal(ChildActivity, ChildGoal).

% descendant_activity(ChildActivity, Activity) if
%   child_activity(ChildActivity, Activity)
holds(descendant_activity(ChildActivity, Activity), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep).

% descendant_activity(GrandChildActivity, Activity) if
%   descendant_activity(ChildActivity, Activity), descendant_activity(GrandChildActivity, ChildActivity)
holds(descendant_activity(GrandChildActivity, Activity), timestep) :-
    holds(descendant_activity(ChildActivity, Activity), timestep),
    holds(descendant_activity(GrandChildActivity, ChildActivity), timestep).

% minor(ChildActivity) if
%   child_activity(ChildActivity, Activity)
holds(minor(ChildActivity), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep).

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
%   active_goal(Goal), activity_goal(ChildActivity, MinorGoal),
%   -MinorGoal, activity_status(ChildActivity, -1)
holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    activity_goal(ChildActivity, MinorGoal),
    -holds(MinorGoal, timestep),
    holds(activity_status(ChildActivity, activity_index__non_active), timestep).

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
%   activity_goal(ChildActivity, MinorGoal), activity_status(ChildActivity, ChildActivityIndex),
%   activity_length(ChildActivity, ChildActivityLength)
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    -holds(MinorGoal, timestep),
    activity_goal(ChildActivity, MinorGoal),
    holds(activity_status(ChildActivity, ChildActivityIndex), timestep),
    activity_length(ChildActivity, ChildActivityLength),
    ChildActivityIndex = ChildActivityLength.

%--- Misc. ---%

% in_progress(Activity) if
%   active_activity(Activity), activity_goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Activity), timestep) :-
    holds(active_activity(Activity), timestep),
    activity_goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% in_progress(Goal) if
%   active_activity(Activity), activity_goal(Activity, Goal), active_goal(Goal)
holds(in_progress(Goal), timestep) :-
    holds(active_activity(Activity), timestep),
    activity_goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% next_action(Activity, Action) if
%   physical_action(Action), agent_action(Action), activity_status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), in_progress(Activity)
holds(next_action(Activity, Action), timestep) :-
    physical_action(Action),
    agent_action(Action),
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, Action),
    holds(in_progress(Activity), timestep).

% next_action(Activity, start(ChildActivity)) if
%   activity_status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), -active_activity(ChildActivity)
holds(next_action(Activity, start(ChildActivity)), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, ChildActivity),
    holds(in_progress(Activity), timestep),
    -holds(active_activity(ChildActivity), timestep).

% next_action(Activity, Action) if
%   agent_action(Action), activity_status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), in_progress(ChildActivity), next_action(ChildActivity, Action)
holds(next_action(Activity, Action), timestep) :-
    agent_action(Action),
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, ChildActivity),
    holds(in_progress(Activity), timestep),
    holds(in_progress(ChildActivity), timestep),
    holds(next_action(ChildActivity, Action), timestep).

% next_action(Activity, stop(ChildActivity)) if
%   activity_status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   in_progress(Activity), active_activity(ChildActivity),
%   activity_goal(ChildActivity, ChildGoal), -active_goal(ChildGoal)
holds(next_action(Activity, stop(ChildActivity)), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, ChildActivity),
    holds(in_progress(Activity), timestep),
    holds(active_activity(ChildActivity), timestep),
    activity_goal(ChildActivity, ChildGoal),
    -holds(active_goal(ChildGoal), timestep).

% Action causes activity_status(Activity, ActivityIndex + 1) if
%   next_action(Activity, Action), activity_status(Activity, ActivityIndex),
%   component(Activity, ActivityIndex + 1, Action), physical_action(Action), agent_action(Action)
holds(activity_status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(Action, timestep),
    holds(next_action(Activity, Action), timestep),
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, Action),
    physical_action(Action),
    agent_action(Action).

% stop(ChildActivity) causes activity_status(Activity, ActivityIndex + 1) if
%   activity_status(Activity, ActivityIndex), component(Activity, ActivityIndex + 1, ChildActivity),
%   next_action(Activity, stop(ChildActivity))
holds(activity_status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(stop(ChildActivity), timestep),
    holds(activity_status(Activity, ActivityIndex), timestep),
    component(Activity, ActivityIndex + 1, ChildActivity),
    holds(next_action(Activity, stop(ChildActivity)), timestep).

% stop(Activity) causes activity_status(ChildActivity, -1) if
%   descendant_activity(ChildActivity, Activity)
holds(activity_status(ChildActivity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep),
    holds(descendant_activity(ChildActivity, Activity), timestep).

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
