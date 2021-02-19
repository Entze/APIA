% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
% and Blount. 2013. "An architecture for intentional agents"

%%%% Step 1 %%%%
#program aia_step_1(current_timestep).

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

:-
    Timestep < current_timestep,
    agent_action(Action),
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

-occurs(Action, Timestep) :-
    Timestep < current_timestep,
    -happened(Action, Timestep).

{ apply_cr_rule(diagnosis(Action, Timestep)) } :-
    step(Timestep),
    physical_action(Action),
    exogenous_action(Action),
    Timestep < current_timestep.

occurs(Action, Timestep) :-
    apply_cr_rule(diagnosis(Action, Timestep)).

:~
    apply_cr_rule(diagnosis(Action, Timestep)). [1@1, diagnosis(Action, Timestep)]

unobserved(Action, Timestep) :-
    Timestep < current_timestep,
    physical_action(Action),
    exogenous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, current_timestep) :-
    UnobservedActions = #count{ Action : unobserved(Action, current_timestep) }.

% Misc

occurs(Action, Timestep) :-
    Timestep <= current_timestep,
    happened(Action, Timestep).

%%%% Step 2 %%%%
#program aia_step_2(current_timestep).

interpretation(ActionsNeeded, current_timestep) :-
    number_unobserved(UnobservedActions, current_timestep),
    ActionsNeeded = UnobservedActions.

:-
    number_unobserved(UnobservedActions, current_timestep),
    interpretation(ActionsNeeded, current_timestep),
    UnobservedActions != ActionsNeeded.

%--- Category 1 ---%
% "there are no activities or goals that are active in cm_n"

category_1_history(current_timestep) :-
    current_timestep > 1,  % TODO: Consider removing this line (our addition)
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
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"

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
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"

category_3_history(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
    holds(in_progress(Activity), current_timestep).

occurs(Action, FutureTimestep) :-
    category_3_history(Activity, current_timestep),
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    -holds(minor(Activity), FutureTimestep),
    holds(in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, Action), FutureTimestep),
    not impossible(Action, FutureTimestep).

projected_success(Activity, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    -holds(minor(Activity), current_timestep),
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
    projected_success(Activity, current_timestep).

{ apply_cr_rule(futile_activity(Activity, current_timestep)) } :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep).

futile(Activity, current_timestep) :-
    apply_cr_rule(futile_activity(Activity, current_timestep)).

:~
    apply_cr_rule(futile_activity(Activity, current_timestep)). [1@1, futile(Activity, current_timestep)]

:-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    -projected_success(Activity, current_timestep).

intended_action(stop(Activity), current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_3_history(Activity, current_timestep),
    futile(Activity, current_timestep).

%--- Category 4 ---%
% "there is a goal g that is active in cm_n but no activity with goal g is active in cm_n"

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
    apply_cr_rule(futile_goal(Goal, current_timestep)). [1@1, futile_goal(Goal, current_timestep)]

intended_action(wait, current_timestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    futile(Goal, current_timestep).

some_action_occurred(FutureTimestep) :-
    interpretation(UnobservedActions, current_timestep),
    current_timestep <= FutureTimestep,
    occurs(Action, FutureTimestep).

%--- Creating new candidates ---%

goal(Activity, Goal) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep).

{ apply_cr_rule(plan_new(Action, FutureTimestep)) } :-
    action(Action),
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    apply_cr_rule(plan_new(Action, FutureTimestep)).

:~
    apply_cr_rule(plan_new(Action, FutureTimestep)). [1@1, plan_new(Action, FutureTimestep)]

component(Activity, PreviousTimestep - 1, Action) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    occurs(Action, PreviousTimestep).

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
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    new_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    has_component(Activity, ActivityLength),
    not has_component(Activity, ActivityLength + 1).

%--- Creating existing candidates ---%

{ apply_cr_rule(plan_existing(Action, FutureTimestep)) } :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    holds(next_action(Activity, Action), FutureTimestep),
    some_action_occurred(FutureTimestep - 1).

occurs(Action, FutureTimestep) :-
    apply_cr_rule(plan_existing(Action, FutureTimestep)).

:~
    apply_cr_rule(plan_existing(Action, FutureTimestep)). [1@1, plan_existing(Action, FutureTimestep)]

occurs(NextAction, FutureTimestep) :-
    interpretation(UnobservedActions, current_timestep),
    category_4_history(Goal, current_timestep),
    existing_candidate(Activity, current_timestep),
    occurs(start(Activity), current_timestep),
    current_timestep < FutureTimestep,
    holds(in_progress(Activity), FutureTimestep),
    holds(next_action(Activity, NextAction), FutureTimestep).

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
    apply_cr_rule(futile_goal(Goal, Timestep)). [1@2, plan_new(Action, Timestep), futile_goal(Goal, Timestep)]

% prefer(plan_existing(Action, Timestep), futile_goal(Goal, Timestep)).
:~
    action(Action),
    not apply_cr_rule(plan_existing(Action, Timestep)),
    apply_cr_rule(futile_goal(Goal, Timestep)). [1@2, plan_existing(Action, Timestep), futile_goal(Goal, Timestep)]
