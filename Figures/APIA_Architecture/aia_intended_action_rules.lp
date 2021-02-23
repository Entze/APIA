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

category_1_history(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    not active_goal_or_activity(current_timestep).

active_goal_or_activity(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    holds(active_goal(Goal), current_timestep).

active_goal_or_activity(current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    holds(active(Activity), current_timestep).

intended_action(wait, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_1_history(current_timestep).

%--- Category 2 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"
% (p. 45) of dissertation
%
% See p. 65 of dissertation

category_2_history(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    holds(active(Activity), current_timestep),
    goal(Activity, Goal),
    -active_goal(Goal).

intended_action(stop(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_2_history(Activity, current_timestep).

%--- Category 3 ---%
% "Let cm_n be the current mental state of history \tau_n"
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"
% (p. 45) of dissertation

category_3_history(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    holds(in_progress(Activity), current_timestep).

occurs(Action, FutureTimestep) :-
    step(FutureTimestep),
    category_3_history(Activity, current_timestep),
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    -holds(minor(Activity), FutureTimestep),
    holds(in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, Action), FutureTimestep),
    agent_action(Action),
    not impossible(Action, FutureTimestep).

projected_success(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    step(FutureTimestep),
    current_timestep < FutureTimestep,
    holds(active(Activity), FutureTimestep),
    goal(Activity, Goal),
    holds(Goal, FutureTimestep).

-projected_success(Activity, current_timestep) :-
    activity(Activity),
    interpretation(UnobservedActions, current_timestep),
    not projected_success(Activity, current_timestep).

intended_action(Action, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    holds(next_action(Activity, Action), current_timestep),
    agent_action(Action),
    projected_success(Activity, current_timestep).

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

category_4_history(Goal, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Goal), current_timestep),
    holds(active_goal(Goal), current_timestep),
    -holds(in_progress(Goal), current_timestep).

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

:-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    occurs(start(Activity), current_timestep),
    -projected_success(Activity, current_timestep),
    not futile(Goal, current_timestep).

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

some_action_occurred(FutureTimestep) :-
    step(FutureTimestep),
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    occurs(Action, FutureTimestep).

%--- Creating new candidates ---%
%
% See p. 71 of dissertation

goal(Activity, Goal) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep).

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

component(Activity, PreviousTimestep - 1, Action) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    occurs(Action, PreviousTimestep),
    physical_action(Action),
    agent_action(Action).

:-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    component(Activity, ActivityIndex, ActivityComponent1),
    component(Activity, ActivityIndex, ActivityComponent2),
    ActivityComponent1 != ActivityComponent2.

has_component(Activity, ActivityIndex) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    component(Activity, ActivityIndex, ActivityComponent).

length(Activity, ActivityLength) :-
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

intended_action(start(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    projected_success(Activity, current_timestep).

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
