% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
% and Blount. 2013. "An architecture for intentional agents"
%
% See p. 63 of dissertation

%%%% Step 2 %%%%
#program aia_intended_action_rules(current_timestep).

#const max_len = 10. % TODO: Update this

% TODO: Consider removing this addition
interpretation(ActionsNeeded, current_timestep) :-
    number_unobserved(UnobservedActions, current_timestep),
    ActionsNeeded = UnobservedActions.

% "This constraint prevents the agent from assuming additional occurrences of exogenous actions."
% (p. 63) of dissertation
:-
    number_unobserved(UnobservedActions, current_timestep),
    interpretation(ActionsNeeded, current_timestep),
    UnobservedActions != ActionsNeeded.

%--- Category 1 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there are no activities or goals that are active in cm_n"
% (p. 45) of dissertation
%
% See p. 65 of dissertation

% "The history is of category 1 when there are no active goals or activities."
% (p. 64) of dissertation
category_1_history(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    not active_goal_or_activity(current_timestep).

active_goal_or_activity(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    holds(active_goal(Goal), current_timestep).

active_goal_or_activity(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    holds(active_activity(Activity), current_timestep).

intended_action(wait, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_1_history(current_timestep).

%--- Category 2 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"
% (p. 45) of dissertation
%
% See p. 65 of dissertation

% "The history is of category 2 when a top-level activity is active
%  but the goal of the activity is not."
% (p. 64) of dissertation
category_2_history(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    holds(active_activity(Activity), current_timestep),
    goal(Activity, Goal),
    -active_goal(Goal).

intended_action(stop(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_2_history(Activity, current_timestep).

%--- Category 3 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"
% (p. 45) of dissertation

% "The history is of category 3 when a top-level activity and its goal are both active
%  (i.e. the activity is in progress)"
% (p. 64) of dissertation
%
% TODO: Shouldn't this also hold for at least current_timestep + 1?
category_3_history(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    holds(in_progress(Activity), current_timestep).

% "we first formalize the notion of a continued execution of an activity from the current step.
%  Recall that a continued execution of an activity is a trajectory whose arcs
%  are labeled by the remaining actions of the activity."
% (p. 66) of dissertation
occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    % TODO: We need this to hold, but it won't until current_timestep >= 2
    category_3_history(Activity, current_timestep),
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    -holds(minor(Activity), FutureTimestep),
    holds(in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, Action), FutureTimestep),
    agent_action(Action),
    not impossible(Action, FutureTimestep).

% "The following rule describes the successful outcome of a continued execution"
% (p. 66) of dissertation
projected_success(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    step(FutureTimestep),
    current_timestep < FutureTimestep,
    holds(active_activity(Activity), FutureTimestep),  % TODO: Needs the above rule to hold
    goal(Activity, Goal),
    holds(Goal, FutureTimestep).

-projected_success(Activity, current_timestep) :-
    activity(Activity),
    interpretation(UnobservedActions, current_timestep),
    not projected_success(Activity, current_timestep).

% "the intended action of a history of category 3 is the next action of the top-level activity
%  when there is a successful continued execution from a possible current state"
% (p. 66) of dissertation
intended_action(Action, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    holds(next_action(Activity, Action), current_timestep),
    agent_action(Action),
    projected_success(Activity, current_timestep).

% --------------------

{ apply_cr_rule(futile_activity(Activity, current_timestep)) } :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep).

futile(Activity, current_timestep) :-
    apply_cr_rule(futile_activity(Activity, current_timestep)).

:~
    apply_cr_rule(futile_activity(Activity, current_timestep)).
    [1@1, futile(Activity, current_timestep)]

:-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep).

% "the intended action of a history of category 3 is [to stop the activity
%  when there is *no* successful continued execution from a possible current state]"
% (p. 66) of dissertation
intended_action(stop(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    futile(Activity, current_timestep).

%--- Category 4 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there is a goal g that is active in cm_n but no activity with goal g is active in cm_n"
% (p. 45) of dissertation
%
% See p. 68 of dissertation

% "The history is of category 4 when a top-level goal is active
%  but no activity with the goal is active (i.e the goal is not in progress)"
% (p. 65) of dissertation
category_4_history(Goal, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Goal), current_timestep),
    holds(active_goal(Goal), current_timestep),
    -holds(in_progress(Goal), current_timestep).

% --------------------
%
% "The following rules give the ASP denitions of new and existing candidate activities"
% (p. 68) of dissertation

existing_candidate(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    holds(next_name(NextActivity), current_timestep),
    Activity < NextActivity,
    goal(Activity, Goal).

new_candidate(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    holds(next_name(Activity), current_timestep).

candidate(Activity, current_timestep) :-
    new_candidate(Activity, current_timestep).

candidate(Activity, current_timestep) :-
    existing_candidate(Activity, current_timestep).

% --------------------
%
% "The following rules guarantee that each answer set contains
% at most the starting of a single candidate activity."
% (p. 69) of dissertation

% TODO: Why does this not produce occurs(start(1), 1)?
occurs(start(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    candidate(Activity, current_timestep),
    goal(Activity, Goal),
    not impossible(start(Activity), current_timestep).

impossible(start(OtherActivity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    goal(Activity, Goal),
    occurs(start(Activity), current_timestep),
    activity(OtherActivity),
    OtherActivity != Activity.

% --------------------

% "The following rule guarantees that candidates that are started by rule (5.31)
%  achieve the goal by forbidding all answer sets where -projected success
%  (i.e. the execution of the candidate is not successful)"
% (p. 70) of dissertation
:-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),
    not futile(Goal, current_timestep).

% "If none are left then the goal is futile and the intended action is dened by rules"
% (p. 70) of dissertation
{ apply_cr_rule(futile_goal(Goal, current_timestep)) } :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep).

futile(Goal, current_timestep) :-
    apply_cr_rule(futile_goal(Goal, current_timestep)).

:~
    apply_cr_rule(futile_goal(Goal, current_timestep)).
    [1@1, futile_goal(Goal, current_timestep)]

intended_action(wait, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    futile(Goal, current_timestep).

%--- Creating new candidates ---%
%
% See p. 71 of dissertation

some_action_occurred(FutureTimestep) :-
    step(FutureTimestep),
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    occurs(Action, FutureTimestep).

% --------------------
%
% "To describe a new candidate we must give it a name, goal, and plan."
% (p. 71) of dissertation

goal(Activity, Goal) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep).

% "[this rule] generates a minimal uninterrupted sequence of occurrences of physical actions"
% (p. 71) of dissertation
{ apply_cr_rule(plan_new(Action, FutureTimestep)) } :-
    step(FutureTimestep),
    physical_action(Action),
    agent_action(Action),
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    apply_cr_rule(plan_new(Action, FutureTimestep)).

:~
    apply_cr_rule(plan_new(Action, FutureTimestep)).
    [1@1, plan_new(Action, FutureTimestep)]

% "[this rule] creates component statements based on those occurrences"
% (p. 71) of dissertation
component(Activity, PreviousTimestep - 1, Action) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    occurs(Action, PreviousTimestep),
    physical_action(Action),
    agent_action(Action).

% "[this rule] guarantees that multiple actions do not have the same index."
% (p. 71) of dissertation
:-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    activity_component(Activity, ActivityIndex, ActivityComponent1),
    activity_component(Activity, ActivityIndex, ActivityComponent2),
    ActivityComponent1 != ActivityComponent2.

% --------------------
%
% "[this rule] describes the length of the new candidate."
% (p. 71) of dissertation

% TODO: Remove has_component() with:
%   #max{ ActivityIndex : activity_component(Activity, ActivityIndex, ActivityComponent) }
has_component(Activity, ActivityIndex) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    activity_component(Activity, ActivityIndex, ActivityComponent).

activity_length(Activity, ActivityLength) :-
    ActivityLength <= max_len,
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    has_component(Activity, ActivityLength),
    not has_component(Activity, ActivityLength + 1).

%--- Creating existing candidates ---%
%
% See p. 73 of dissertation

% "The following rule generates the minimal number of occurrences of physical actions
%  defined by the plan of the existing candidate."
% (p. 73) of dissertation
{ apply_cr_rule(plan_existing(Action, FutureTimestep)) } :-
    step(FutureTimestep),
    physical_action(Action),
    agent_action(Action),
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    apply_cr_rule(plan_existing(Action, FutureTimestep)).

:~
    apply_cr_rule(plan_existing(Action, FutureTimestep)).
    [1@1, plan_existing(Action, FutureTimestep)]

% "The following rule generates the occurrences of mental agent actions
%  that may be a part of the total execution of an existing activity.
%  Note that this rule is required for existing activities because they may be nested"
% (p. 73) of dissertation
occurs(NextAction, FutureTimestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    holds(in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, NextAction), FutureTimestep),
    mental_action(Action),
    agent_action(Action).

% "The next rule describes the intended action to start a candidate activity
%  (new or existing)
%  whose execution is expected to achieve the goal
%  in as few occurrences of physical actions as possible."
% (p. 73) of dissertation
intended_action(start(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    projected_success(Activity, current_timestep).

% --------------------

% "The last two rules are preference statements of CR-Prolog and ensure that a goal is futile
%  only if there is no candidate that is expected to achieve the goal.
% (p. 74) of dissertation

% prefer(plan_new(Action, Timestep), futile_goal(Goal, Timestep)).
:~
    action(Action),
    not apply_cr_rule(plan_new(Action, Timestep)),
    apply_cr_rule(futile_goal(Goal, Timestep)).
    [1@2, plan_new(Action, Timestep), futile_goal(Goal, Timestep)]

% prefer(plan_existing(Action, Timestep), futile_goal(Goal, Timestep)).
:~
    action(Action),
    not apply_cr_rule(plan_existing(Action, Timestep)),
    apply_cr_rule(futile_goal(Goal, Timestep)).
    [1@2, plan_existing(Action, Timestep), futile_goal(Goal, Timestep)]
