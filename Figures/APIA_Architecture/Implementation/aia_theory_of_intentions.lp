% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
#program base.

#const activity_index__non_active = -1.
#const activity_index__new = 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% goal(Goal)
% activity(Activity)

% Note: Our addition
activity(Activity) :-
    Activity = 1..(ir + 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% activity_component(Activity, ComponentIndex, Component)
% activity_length(Activity, ActivityLength)
% activity_goal(Activity, ActivityGoal)

activity_length(Activity, ActivityLength) :-
    activity(Activity),
    Activity < ir,
    ActivityLength = #max{ ComponentIndex :
        activity_component(Activity, ComponentIndex, _)
    }.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_mental_fluents(max_activity_length).

% Note: We introduce physical_fluent/2
fluent(Type, Fluent) :-
    physical_fluent(Type, Fluent).

% Note: We introduce mental_fluent/2
fluent(Type, Fluent) :-
    mental_fluent(Type, Fluent).

mental_fluent(inertial, active_goal(Goal)) :-
    goal(Goal).

% Note: Originally, status(Activity, ActivityIndex)
mental_fluent(inertial, activity_status(Activity, ActivityIndex)) :-
    Activity != (ir; ir + 1),  % Note: Our addition
    activity_length(Activity, ActivityLength),
    ActivityIndex = -1..ActivityLength.

% Note: Our addition
mental_fluent(inertial, activity_status(Activity, ActivityIndex)) :-
    Activity = (ir; ir + 1),
    ActivityIndex = -1..max_activity_length.

% Note: Originally, active(Activity)
mental_fluent(defined, active_activity(Activity)) :-
    activity(Activity).

% Note: Originally, child(ChildActivity, Activity)
%               or, immediate_child(ChildActivity, Activity)
mental_fluent(defined, child_activity(ChildActivity, Activity)) :-
    activity(Activity),
    activity(ChildActivity),
    ChildActivity != Activity.

% Note: Originally, child_goal(ChildActivity, Activity)
%               or, immediate_child_goal(ChildActivity, Activity)
mental_fluent(defined, child_goal(ChildGoal, Goal)) :-
    goal(Goal),
    goal(ChildGoal),
    ChildGoal != Goal.

% Note: Originally, descendant(ChildActivity, Activity)
mental_fluent(defined, descendant_activity(ChildActivity, Activity)) :-
    activity(Activity),
    activity(ChildActivity),
    ChildActivity != Activity.

% Note: Originally, minor(Activity)
mental_fluent(defined, minor_activity(Activity)) :-
    activity(Activity).

% Note: Originally, minor(Goal)
mental_fluent(defined, minor_goal(Goal)) :-
    goal(Goal).

% Note: Originally, in_progress(Activity)
mental_fluent(defined, activity_in_progress(Activity)) :-
    activity(Activity).

% Note: Originally, in_progress(Goal)
mental_fluent(defined, goal_in_progress(Goal)) :-
    goal(Goal).

mental_fluent(defined, next_action(Activity, Action)) :-
    activity(Activity),
    action(Action).

mental_fluent(inertial, next_name(Activity)) :-
    activity(Activity).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% -activity_status(Activity, OldActivityIndex) if
%   activity_status(Activity, ActivityIndex),
%   OldActivityIndex != ActivityIndex
%
% (p. 29) of dissertation
-holds(activity_status(Activity, OldActivityIndex), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    mental_fluent(inertial, activity_status(Activity, OldActivityIndex)),
    OldActivityIndex != ActivityIndex.

% active_activity(Activity) if
%   -activity_status(Activity, -1)
%
% (p. 29) of dissertation
holds(active_activity(Activity), timestep) :-
    -holds(activity_status(Activity, activity_index__non_active), timestep).

% start(Activity)
%   causes activity_status(Activity, 0)
%
% (p. 29) of dissertation
holds(activity_status(Activity, activity_index__new), timestep + 1) :-
    occurs(start(Activity), timestep).

% stop(Activity)
%   causes activity_status(Activity, -1)
%
% (p. 29) of dissertation
holds(activity_status(Activity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep).

% impossible start(Activity) if
%   active_activity(Activity)
%
% (p. 29) of dissertation
impossible(start(Activity), timestep) :-
    holds(active_activity(Activity), timestep).

% impossible stop(Activity) if
%   -active_activity(Activity)
%
% (p. 29) of dissertation
impossible(stop(Activity), timestep) :-
    -holds(active_activity(Activity), timestep).

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible Action1, Action2 if
%   mental_action(Action1),
%   agent_action(Action1),
%   agent_action(Action2),
%   Action1 != Action2.
%
% (p. 29) of dissertation
%   Note: We have condensed this rule
impossible(Action1, timestep) :-
    mental_action(Action1),
    agent_action(Action1),
    agent_action(Action2),
    Action1 != Action2,
    occurs(Action2, timestep).

impossible(Action2, timestep) :-
    mental_action(Action1),
    agent_action(Action1),
    agent_action(Action2),
    Action1 != Action2,
    occurs(Action1, timestep).

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, Action if
%   agent_action(Action).
%
% (p. 29) of dissertation
%   Note: We have condensed this rule
impossible(wait, timestep) :-
    agent_action(Action),
    occurs(Action, timestep).

impossible(Action, timestep) :-
    agent_action(Action),
    occurs(wait, timestep).

% child_activity(ChildActivity, Activity) if
%   activity_status(Activity, ActivityIndex),
%   activity_component(Activity, ActivityIndex + 1, ChildActivity)
%
% (p. 30) of dissertation
holds(child_activity(ChildActivity, Activity), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, ChildActivity),
    activity(ChildActivity).

% child_goal(ChildGoal, Goal) if
%   child_activity(ChildActivity, Activity),
%   activity_goal(Activity, Goal),
%   activity_goal(ChildActivity, ChildGoal)
%
% (p. 30) of dissertation
holds(child_goal(ChildGoal, Goal), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep),
    activity_goal(Activity, Goal),
    activity_goal(ChildActivity, ChildGoal).

% descendant_activity(ChildActivity, Activity) if
%   child_activity(ChildActivity, Activity)
%
% (p. 30) of dissertation
holds(descendant_activity(ChildActivity, Activity), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep).

% descendant_activity(GrandChildActivity, Activity) if
%   descendant_activity(ChildActivity, Activity),
%   descendant_activity(GrandChildActivity, ChildActivity)
%
% (p. 30) of dissertation
holds(descendant_activity(GrandChildActivity, Activity), timestep) :-
    holds(descendant_activity(ChildActivity, Activity), timestep),
    holds(descendant_activity(GrandChildActivity, ChildActivity), timestep).

% minor_activity(ChildActivity) if
%   child_activity(ChildActivity, Activity)
%
% (p. 30) of dissertation
holds(minor_activity(ChildActivity), timestep) :-
    holds(child_activity(ChildActivity, Activity), timestep).

% minor_goal(ChildGoal) if
%   child_goal(ChildGoal, Goal)
%
% (p. 30) of dissertation
holds(minor_goal(ChildGoal), timestep) :-
    holds(child_goal(ChildGoal, Goal), timestep).

% select(Goal)
%   causes active_goal(Goal)
%
% (p. 30) of dissertation
holds(active_goal(Goal), timestep + 1) :-
    occurs(select(Goal), timestep).

% impossible select(Goal) if
%   active_goal(Goal)
%
% (p. 31) of dissertation
impossible(select(Goal), timestep) :-
    holds(active_goal(Goal), timestep).

% abandon(Goal)
%   causes -active_goal(Goal)
%
% (p. 30) of dissertation
-holds(active_goal(Goal), timestep + 1) :-
    occurs(abandon(Goal), timestep).

% impossible abandon(Goal) if
%   -active_goal(Goal)
%
% (p. 31) of dissertation
impossible(abandon(Goal), timestep) :-
    -holds(active_goal(Goal), timestep).

% impossible abandon(Goal) if
%   minor_goal(Goal)
%
% (p. 31) of dissertation
impossible(abandon(Goal), timestep) :-
    holds(minor_goal(Goal), timestep).

% "We assume that no [action other than wait] may occur concurrently with a special exogenous action"
%
% impossible Action1, Action2 if
%   mental_action(Action1),
%   special_exogenous_action(Action1),
%   action(Action2),
%   Action2 != wait,
%   Action1 != Action2
%
% (p. 31) of dissertation
%   Note: We have condensed this rule (and modified it to consider policy actions)
impossible(Action1, timestep) :-
    mental_action(Action1),
    special_exogenous_action(Action1),
    action(Action2),
    Action2 != wait,
    Action1 != Action2,
    occurs(Action2, timestep).

impossible(Action2, timestep) :-
    mental_action(Action1),
    special_exogenous_action(Action1),
    action(Action2),
    Action2 != wait,
    Action1 != Action2,
    occurs(Action1, timestep).

% -active_goal(Goal) if
%   -minor_goal(Goal),
%   Goal
%
% (p. 31) of dissertation
-holds(active_goal(Goal), timestep) :-
    -holds(minor_goal(Goal), timestep),
    holds(Goal, timestep).

%--- Sub goal ---%

% "An unachieved minor goal MinorGoal of an activity ChildActivity becomes active when ChildActivity is the next component of an ongoing activity Activity"
%
% active_goal(MinorGoal) if
%   minor_goal(MinorGoal),
%   child_goal(MinorGoal, Goal),
%   active_goal(Goal),
%   activity_goal(ChildActivity, MinorGoal),
%   -MinorGoal,
%   activity_status(ChildActivity, -1)
%
% (p. 31) of dissertation
holds(active_goal(MinorGoal), timestep) :-
    holds(minor_goal(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    activity_goal(ChildActivity, MinorGoal),
    -holds(MinorGoal, timestep),
    holds(activity_status(ChildActivity, activity_index__non_active), timestep).

% "A minor goal MinorGoal is no longer active when it is achieved."
%
% -active_goal(MinorGoal) if
%   minor_goal(MinorGoal),
%   child_goal(MinorGoal, Goal),
%   active_goal(Goal),
%   MinorGoal.
%
% (p. 32) of dissertation
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor_goal(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    holds(MinorGoal, timestep).

% "A minor goal MinorGoal is no longer active when its parent [goal] is no longer active"
%
% -active_goal(MinorGoal) if
%   minor_goal(MinorGoal),
%   child_goal(MinorGoal, Goal),
%   -active_goal(Goal)
%
% (p. 32) of dissertation
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor_goal(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    -holds(active_goal(Goal), timestep).

% "A minor goal MinorGoal of ChildActivity is no longer active when ChildActivity has been executed."
%
% -active_goal(MinorGoal) if
%   minor_goal(MinorGoal),
%   child_goal(MinorGoal, Goal),
%   active_goal(Goal),
%   -MinorGoal,
%   activity_goal(ChildActivity, MinorGoal),
%   activity_status(ChildActivity, ChildActivityIndex),
%   activity_length(ChildActivity, ChildActivityLength)
%
% (p. 32) of dissertation
-holds(active_goal(MinorGoal), timestep) :-
    holds(minor_goal(MinorGoal), timestep),
    holds(child_goal(MinorGoal, Goal), timestep),
    holds(active_goal(Goal), timestep),
    -holds(MinorGoal, timestep),
    activity_goal(ChildActivity, MinorGoal),
    holds(activity_status(ChildActivity, ChildActivityIndex), timestep),
    activity_length(ChildActivity, ChildActivityLength),
    ChildActivityIndex = ChildActivityLength.

%--- Misc. ---%

% activity_in_progress(Activity) if
%   active_activity(Activity),
%   activity_goal(Activity, Goal),
%   active_goal(Goal)
%
% (p. 33) of dissertation
holds(activity_in_progress(Activity), timestep) :-
    holds(active_activity(Activity), timestep),
    activity_goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% goal_in_progress(Goal) if
%   active_activity(Activity),
%   activity_goal(Activity, Goal),
%   active_goal(Goal)
%
% (p. 33) of dissertation
holds(goal_in_progress(Goal), timestep) :-
    holds(active_activity(Activity), timestep),
    activity_goal(Activity, Goal),
    holds(active_goal(Goal), timestep).

% next_action(Activity, Action) if
%   agent_action(Action),
%   not mental_action(Action),
%   activity_status(Activity, ActivityIndex),
%   activity_component(Activity, ActivityIndex + 1, Action),
%   activity_in_progress(Activity)
%
% (p. 33) of dissertation
%   Note: We modify this rule to consider policy actions
holds(next_action(Activity, Action), timestep) :-
    agent_action(Action),
    not mental_action(Action),
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, Action),
    holds(activity_in_progress(Activity), timestep).

% next_action(Activity, start(ChildActivity)) if
%   activity_status(Activity, ActivityIndex),
%   activity_component(Activity, ActivityIndex + 1, ChildActivity),
%   activity_in_progress(Activity),
%   -active_activity(ChildActivity)
%
% (p. 33) of dissertation
holds(next_action(Activity, start(ChildActivity)), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, ChildActivity),
    activity(ChildActivity),
    holds(activity_in_progress(Activity), timestep),
    -holds(active_activity(ChildActivity), timestep).

% next_action(Activity, Action) if
%   agent_action(Action),
%   activity_status(Activity, ActivityIndex),
%   activity_component(Activity, ActivityIndex + 1, ChildActivity),
%   activity_in_progress(Activity),
%   activity_in_progress(ChildActivity),
%   next_action(ChildActivity, Action)
%
% (p. 34) of dissertation
holds(next_action(Activity, Action), timestep) :-
    agent_action(Action),
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, ChildActivity),
    activity(ChildActivity),
    holds(activity_in_progress(Activity), timestep),
    holds(activity_in_progress(ChildActivity), timestep),
    holds(next_action(ChildActivity, Action), timestep).

% next_action(Activity, stop(ChildActivity)) if
%   activity_status(Activity, ActivityIndex),
%   activity_component(Activity, ActivityIndex + 1, ChildActivity),
%   activity_in_progress(Activity),
%   active_activity(ChildActivity),
%   activity_goal(ChildActivity, ChildGoal),
%   -active_goal(ChildGoal)
%
% (p. 34) of dissertation
holds(next_action(Activity, stop(ChildActivity)), timestep) :-
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, ChildActivity),
    activity(ChildActivity),
    holds(activity_in_progress(Activity), timestep),
    holds(active_activity(ChildActivity), timestep),
    activity_goal(ChildActivity, ChildGoal),
    -holds(active_goal(ChildGoal), timestep).

% Action
%   causes activity_status(Activity, ActivityIndex + 1)
%   if
%     next_action(Activity, Action),
%     activity_status(Activity, ActivityIndex),
%     activity_component(Activity, ActivityIndex + 1, Action),
%     agent_action(Action),
%     not mental_action(Action)
%
% (p. 34) of dissertation
%   Note: We modify this rule to consider policy actions
holds(activity_status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(Action, timestep),
    holds(next_action(Activity, Action), timestep),
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, Action),
    agent_action(Action),
    not mental_action(Action).

% stop(ChildActivity)
%   causes activity_status(Activity, ActivityIndex + 1)
%   if
%     activity_status(Activity, ActivityIndex),
%     activity_component(Activity, ActivityIndex + 1, ChildActivity),
%     next_action(Activity, stop(ChildActivity))
%
% (p. 34) of dissertation
holds(activity_status(Activity, ActivityIndex + 1), timestep + 1) :-
    occurs(stop(ChildActivity), timestep),
    holds(activity_status(Activity, ActivityIndex), timestep),
    activity_component(Activity, ActivityIndex + 1, ChildActivity),
    activity(ChildActivity),
    holds(next_action(Activity, stop(ChildActivity)), timestep).

% stop(Activity)
%   causes activity_status(ChildActivity, -1)
%   if
%     descendant_activity(ChildActivity, Activity)
%
% (p. 35) of dissertation
holds(activity_status(ChildActivity, activity_index__non_active), timestep + 1) :-
    occurs(stop(Activity), timestep),
    holds(descendant_activity(ChildActivity, Activity), timestep).

% -next_name(Activity) if
%   next_name(ChildActivity),
%   Activity != ChildActivity
%
% (p. 35) of dissertation
-holds(next_name(Activity), timestep) :-
    next_name(ChildActivity),
    activity(Activity),
    Activity != ChildActivity.

% start(Activity)
%   causes next_name(Activity + 1)
%   if
%     next_name(Activity),
%     -minor_activity(Activity)
%
% (p. 35) of dissertation
holds(next_name(Activity + 1), timestep + 1) :-
    occurs(start(Activity), timestep),
    holds(next_name(Activity), timestep),
    -holds(minor_activity(Activity), timestep).

% Definition of impossible
% (p. 98) of dissertation
-occurs(Action, timestep) :-
    impossible(Action, timestep).
