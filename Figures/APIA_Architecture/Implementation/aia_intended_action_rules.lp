% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
% and Blount. 2013. "An architecture for intentional agents"
%
% Step 2.
%
% See p. 63 of dissertation
#program aia_intended_action_rules(current_timestep, max_activity_length).

% Note: Our addition
%
% Require interpretation/2.
:-
    not interpretation(_, current_timestep).

% "This constraint prevents the agent from assuming additional occurrences of exogenous actions."
% (p. 63) of dissertation
%
% Note: The point in this rule is to limit the inferred exogenous actions from the diagnosis program
%   while the intended action program is running.
%   Since the diagnosis program re-runs every time,
%   interpretation(Step1UnobservedActions, current_timestep) ensures that it does not
%   produce any more actions than what it would have on its own.
:-
    number_unobserved(UnobservedActions, current_timestep),
    interpretation(Step1UnobservedActions, current_timestep),
    UnobservedActions != Step1UnobservedActions.

% "[...] other than the [above constraint], the number x from the flag is not used
%    and the presence of the flag is all that is needed"
%  (p. 63) of dissertation
%
% Note: We remove interpretation/2 from the rules below since
%   the conditional inclusion of this ASP subprogram has the same effect

% ------------------------------------------------------------------------------------------

% (p. 64) of dissertation
active_goal_or_activity(current_timestep) :-
    holds(active_goal(Goal), current_timestep).

% (p. 64) of dissertation
active_goal_or_activity(current_timestep) :-
    holds(active_activity(Activity), current_timestep).

% (p. 71) of dissertation
some_action_occurred(FutureTimestep) :-
    step(FutureTimestep),
    FutureTimestep >= current_timestep,
    occurs(Action, FutureTimestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               (Idle state)
%
% "Let cm_n be the current mental state of history \tau_n"
% "there are no activities or goals that are active in cm_n"
% (p. 45) of dissertation
%
% See p. 65 of dissertation

% "The history is of category 1 when there are no active goals or activities."
% (p. 64) of dissertation
category_1_history(current_timestep) :-
    not active_goal_or_activity(current_timestep).

% "Recall that the agent's intended action is to wait when his history is of category 1"
% (p. 65) of dissertation
intended_action(wait, current_timestep) :-
    category_1_history(current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          (Activity is complete)
%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"
% (p. 45) of dissertation
%
% See p. 65 of dissertation

% "The history is of category 2 when a top-level activity is active
%  but the goal of the activity is not."
% (p. 64) of dissertation
%
% Note: -holds(active_goal(Goal), current_timestep) is our fix
category_2_history(Activity, current_timestep) :-
    -holds(minor_activity(Activity), current_timestep),
    holds(active_activity(Activity), current_timestep),
    activity_goal(Activity, Goal),
    -holds(active_goal(Goal), current_timestep).

% "Recall that the agent's intended action is to wait when his history is of category 1"
% (p. 65) of dissertation
intended_action(stop(Activity), current_timestep) :-
    category_2_history(Activity, current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         (Activity is in progress)
%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"
% (p. 45) of dissertation

% "The history is of category 3 when a top-level activity and its goal are both active
%  (i.e. the activity is in progress)"
% (p. 64) of dissertation
category_3_history(Activity, current_timestep) :-
    -holds(minor_activity(Activity), current_timestep),
    holds(activity_in_progress(Activity), current_timestep).

% "we first formalize the notion of a continued execution of an activity from the current step.
%  Recall that a continued execution of an activity is a trajectory whose arcs
%  are labeled by the remaining actions of the activity."
% (p. 66) of dissertation
occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    category_3_history(Activity, current_timestep),
    FutureTimestep >= current_timestep,
    -holds(minor_activity(Activity), FutureTimestep),
    holds(activity_in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, Action), FutureTimestep),
    agent_action(Action),
    not impossible(Action, FutureTimestep).

% "The following rule describes the successful outcome of a continued execution"
% (p. 66) of dissertation
projected_success(Activity, current_timestep) :-
    -holds(minor_activity(Activity), current_timestep),
    step(FutureTimestep),
    FutureTimestep > current_timestep,
    holds(active_activity(Activity), FutureTimestep),
    activity_goal(Activity, Goal),
    holds(Goal, FutureTimestep).

% (p. 66) of dissertation
-projected_success(Activity, current_timestep) :-
    activity(Activity),
    not projected_success(Activity, current_timestep).

% "the intended action of a history of category 3 is the next action of the top-level activity
%  when there is a successful continued execution from a possible current state"
% (p. 66) of dissertation
intended_action(Action, current_timestep) :-
    category_3_history(Activity, current_timestep),
    holds(next_action(Activity, Action), current_timestep),
    agent_action(Action),
    projected_success(Activity, current_timestep).

% ------------------------------------------------------------------------------------------

% "The following constraint (5.27) forbids all answer sets where -projected_success
%  (i.e. the continued execution of the activity is not successful)"
% (p. 67) of dissertation
:-
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep),
    not futile_activity(Activity, current_timestep).

% "however if there is no such answer set then the activity is futile"
% (p. 67) of dissertation
{ apply_cr_rule(futile_activity(Activity, current_timestep)) } :-
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep).

% Note: Originally, futile(Activity, current_timestep)
futile_activity(Activity, current_timestep) :-
    apply_cr_rule(futile_activity(Activity, current_timestep)).

% "the intended action of a history of category 3 is [to stop the activity
%  when there is *no* successful continued execution from a possible current state]"
% (p. 66-68) of dissertation
intended_action(stop(Activity), current_timestep) :-
    category_3_history(Activity, current_timestep),
    futile_activity(Activity, current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      (We need to start an activity)
%
% "Let cm_n be the current mental state of history \tau_n"
% "there is a goal g that is active in cm_n but no activity with goal g is active in cm_n"
% (p. 45) of dissertation
%
% See p. 68 of dissertation

% "The history is of category 4 when a top-level goal is active
%  but no activity with the goal is active (i.e. the goal is not in progress)"
% (p. 65) of dissertation
category_4_history(Goal, current_timestep) :-
    -holds(minor_goal(Goal), current_timestep),
    holds(active_goal(Goal), current_timestep),
    -holds(goal_in_progress(Goal), current_timestep).

% ------------------------------------------------------------------------------------------
%
% "The following rules give the ASP denitions of new and existing candidate activities"
% (p. 68) of dissertation

existing_candidate(Activity, current_timestep) :-
    category_4_history(Goal, current_timestep),
    holds(next_name(NextActivity), current_timestep),
    Activity < NextActivity,
    activity_goal(Activity, Goal).

new_candidate(Activity, current_timestep) :-
    category_4_history(Goal, current_timestep),
    holds(next_name(Activity), current_timestep).

candidate(Activity, current_timestep) :-
    new_candidate(Activity, current_timestep).

candidate(Activity, current_timestep) :-
    existing_candidate(Activity, current_timestep).

% ------------------------------------------------------------------------------------------
%
% "The following rules guarantee that each answer set contains
%  at most the starting of a single candidate activity."
% (p. 69) of dissertation

occurs(start(Activity), current_timestep) :-
    category_4_history(Goal, current_timestep),
    candidate(Activity, current_timestep),
    activity_goal(Activity, Goal),
    not impossible(start(Activity), current_timestep).

impossible(start(OtherActivity), current_timestep) :-
    category_4_history(Goal, current_timestep),
    activity_goal(Activity, Goal),
    occurs(start(Activity), current_timestep),
    activity(OtherActivity),
    OtherActivity != Activity.

% ------------------------------------------------------------------------------------------

% "The following rule guarantees that candidates that are started by rule (5.31)
%  achieve the goal by forbidding all answer sets where -projected success
%  (i.e. the execution of the candidate is not successful)"
% (p. 70) of dissertation
:-
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),
    not futile_goal(Goal, current_timestep).

% "If none are left then the goal is futile"
% (p. 70) of dissertation
{ apply_cr_rule(futile_goal(Goal, current_timestep)) } :-
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep).

% Note: Originally, futile(Goal, current_timestep)
futile_goal(Goal, current_timestep) :-
    apply_cr_rule(futile_goal(Goal, current_timestep)).

% (p. 70) of dissertation
intended_action(wait, current_timestep) :-
    category_4_history(Goal, current_timestep),
    futile_goal(Goal, current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 4: Creating new candidates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See p. 71 of dissertation

% ------------------------------------------------------------------------------------------
%
% "To describe a new candidate we must give it a name, goal, and plan."
% (p. 71) of dissertation

% "The goal of the new activity is given by the following rule"
% (p. 71) of dissertation
activity_goal(Activity, Goal) :-
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep).

% ------------------------------------------------------------------------------------------
%
% "The plan of a new candidate is defined by the following rules."
% (p. 71) of dissertation

% "[this rule] generates a minimal uninterrupted sequence of occurrences of physical actions"
% (p. 71) of dissertation
{ apply_cr_rule(plan_new(Action, FutureTimestep)) } :-
    step(FutureTimestep),
    agent_action(Action),
    not mental_action(Action),  % Note: Our modification to consider policy actions
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    apply_cr_rule(plan_new(Action, FutureTimestep)).

% "[this rule] creates component statements based on those occurrences"
% (p. 71) of dissertation
activity_component(Activity, FutureTimestep - current_timestep, Action) :-
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    occurs(Action, FutureTimestep),
    FutureTimestep > current_timestep,  % Note: Our addition
    agent_action(Action),
    not mental_action(Action).  % Note: Our modification to consider policy actions

% "[this rule] guarantees that multiple actions do not have the same index."
% (p. 71) of dissertation
:-
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    activity_component(Activity, ActivityIndex, ActivityComponent1),
    activity_component(Activity, ActivityIndex, ActivityComponent2),
    ActivityComponent1 != ActivityComponent2.

% ------------------------------------------------------------------------------------------
%
% "[this rule] describes the length of the new candidate."
% (p. 71) of dissertation

% Note: We removed has_component(...)
activity_length(Activity, ActivityLength) :-
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    ActivityLength = #max{ ActivityIndex :
        activity_component(Activity, ActivityIndex, _)
    },
    ActivityLength > 0,
    ActivityLength <= max_activity_length.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Category 4: Creating existing candidates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% See p. 73 of dissertation

% "The following rule generates the minimal number of occurrences of physical actions
%  defined by the plan of the existing candidate."
% (p. 73) of dissertation
{ apply_cr_rule(plan_existing(Action, FutureTimestep)) } :-
    step(FutureTimestep),
    agent_action(Action),
    not mental_action(Action),  % Note: Our modification to consider policy actions
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1).

% Note: Our addition (Considers planning policy actions)
{ apply_cr_rule(plan_existing(Action, FutureTimestep)) } :-
    step(FutureTimestep),
    policy_action(Action),
    agent_action(Action),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    apply_cr_rule(plan_existing(Action, FutureTimestep)).

% "The following rule generates the occurrences of mental agent actions
%  that may be a part of the total execution of an existing activity.
%  Note that this rule is required for existing activities because they may be nested"
% (p. 73) of dissertation
occurs(NextAction, FutureTimestep) :-
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    holds(activity_in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, NextAction), FutureTimestep),
    mental_action(NextAction),
    agent_action(NextAction).

% "The next rule describes the intended action to start a candidate activity
%  (new or existing)
%  whose execution is expected to achieve the goal
%  in as few occurrences of physical actions as possible."
% (p. 73) of dissertation
intended_action(start(Activity), current_timestep) :-
    category_4_history(Goal, current_timestep),
    candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    projected_success(Activity, current_timestep).

% ------------------------------------------------------------------------------------------

% "The last two rules are preference statements of CR-Prolog and ensure that a goal is futile
%  only if there is no candidate that is expected to achieve the goal.
% (p. 74) of dissertation

% prefer(plan_new(Action, Timestep), futile_goal(Goal, current_timestep)).
:~
    action(Action),
    step(Timestep),
    goal(Goal),

    % Condition of plan_new(Action, Timestep)
    step(FutureTimestep),
    physical_action(Action),
    agent_action(Action),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    some_action_occurred(FutureTimestep - 1),

    % Condition of futile_goal(Goal, current_timestep)
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),

    HigherPriorityCRRule = plan_new(Action, Timestep),
    LowerPriorityCRRule = futile_goal(Goal, current_timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

% Note: Our addition (Considers planning policy actions)
%
% prefer(plan_new(Action, Timestep), futile_goal(Goal, current_timestep)).
:~
    action(Action),
    step(Timestep),
    goal(Goal),

    % Condition of plan_new(Action, Timestep)
    step(FutureTimestep),
    policy_action(Action),
    agent_action(Action),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    some_action_occurred(FutureTimestep - 1),

    % Condition of futile_goal(Goal, current_timestep)
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),

    HigherPriorityCRRule = plan_new(Action, Timestep),
    LowerPriorityCRRule = futile_goal(Goal, current_timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]



% prefer(plan_existing(Action, Timestep), futile_goal(Goal, current_timestep)).
:~
    action(Action),
    step(Timestep),
    goal(Goal),

    % Condition of plan_existing(Action, Timestep)
    step(FutureTimestep),
    physical_action(Action),
    agent_action(Action),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1),

    % Condition of futile_goal(Goal, current_timestep)
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),

    HigherPriorityCRRule = plan_existing(Action, Timestep),
    LowerPriorityCRRule = futile_goal(Goal, current_timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

% Note: Our addition (Considers planning policy actions)
%
% prefer(plan_existing(Action, Timestep), futile_goal(Goal, current_timestep)).
:~
    action(Action),
    step(Timestep),
    goal(Goal),

    % Condition of plan_existing(Action, Timestep)
    step(FutureTimestep),
    policy_action(Action),
    agent_action(Action),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    FutureTimestep > current_timestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1),

    % Condition of futile_goal(Goal, current_timestep)
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),

    HigherPriorityCRRule = plan_existing(Action, Timestep),
    LowerPriorityCRRule = futile_goal(Goal, current_timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

% ------------------------------------------------------------------------------------------

% Blount requires AIA to execute an activity that as a minimal amount of physical actions.
% (p. 47) of dissertation
%
% However, Blount does not require the amount of timesteps in which a physical action is performed to be minimal.
%   (i.e. Blount does not prefer a concurrent execution of actions over a sequence execution of the same actions).
%
% The following minimizes the amount of "physical" timesteps.
%
% Note: Our addition

#const aia_minimize_activity_length = cr_rule_priority - 1.

physical_activity_length(Activity, PhysicalActivityLength) :-
    category_4_history(Goal, current_timestep),
    activity(Activity),
    PhysicalActivityLength = #count{ ActivityIndex :
        activity_component(Activity, ActivityIndex, ActivityComponent),
        physical_action(ActivityComponent)
    },
    PhysicalActivityLength > 0,
    PhysicalActivityLength <= max_activity_length.

#minimize{ PhysicalActivityLength@aia_minimize_activity_length, Activity :
    occurs(start(Activity), current_timestep),
    physical_activity_length(Activity, PhysicalActivityLength)
}.
