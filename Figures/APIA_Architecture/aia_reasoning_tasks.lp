% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
% and Blount. 2013. "An architecture for intentional agents"

%%%% Step 1 %%%%
#program aia_step_1.

occurs(Action, Timestep) :-
    current_step(CurrentTimestep),
    Timestep < CurrentTimestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

:-
    current_step(CurrentTimestep),
    Timestep < CurrentTimestep,
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

-occurs(Action, Timestep) :-
    current_step(CurrentTimestep),
    Timestep < CurrentTimestep,
    -happened(Action, Timestep).

{ apply_cr_rule(d(Action, I2)) } :-
    current_step(CurrentTimestep),
    physical_exogeneous_action(Action),
    I2 < CurrentTimestep.

occurs(Action, I2) :-
    apply_cr_rule(d(Action, I2)).

:~
    apply_cr_rule(d(Action, I2)). [1@1, d(Action, I2)]

unobserved(Action, Timestep) :-
    current_step(CurrentTimestep),
    Timestep < CurrentTimestep,
    physical_exogeneous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, Timestep) :-
    current_step(Timestep),
    UnobservedActions = #count{ unobserved(EX, IX) }.

%%%% Step 2 %%%%
#program aia_step_2.

:-
    current_step(Timestep),
    number_unobserved(UnobservedActions, Timestep),
    interpretation(ActionsNeeded, Timestep),
    UnobservedActions != ActionsNeeded.

%--- Category 1 ---%
% "there are no activities or goals that are active in cm_n"

category_1_history(Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    not active_goal_or_activity(Timestep).

active_goal_or_activity(Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    holds(active_goal(G), Timestep).

active_goal_or_activity(Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    holds(active(Activity), Timestep).

intended_action(wait, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_1_history(Timestep).

%--- Category 2 ---%
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"

category_2_history(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    -holds(minor(Activity), Timestep),
    holds(active(Activity), Timestep),
    goal(Activity, G),
    -active_goal(G).

intended_action(stop(Activity), Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_2_history(Activity, Timestep).

%--- Category 3 ---%
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"

category_3_history(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    -holds(minor(Activity) Timestep),

occurs(Action, I1) :-
    current_step(Timestep),
    category_3_history(Activity, Timestep),
    interpretation(UnobservedActions, Timestep),
    Timestep <= I1,
    -holds(minor(Activity), I1),
    holds(in_progress(Activity), I1),
    holds(next_action(Activity, Action), I1),
    not impossible(Action, I1).

projected_success(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    -holds(minor(Activity), Timestep),
    Timestep < I1,
    holds(active(Activity), I1),
    goal(Activity, G),
    holds(G, I1).

-projected_success(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    not projected_success(Activity, Timestep).

intended_action(Action, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_3_history(Activity, Timestep),
    holds(next_action(Activity, Action), Timestep),
    projected_success(Activity, Timestep).

{ apply_cr_rule(f(Activity, Timestep)) } :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_3_history(Activity, Timestep),
    -projected_success(Activity, Timestep).

futile(Activity, Timestep) :-
    apply_cr_rule(f(Activity, Timestep)).

:~
    apply_cr_rule(f(Activity, Timestep)). [1@1, f(Activity, Timestep)]

:-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_3_history(Activity, Timestep),
    -projected_success(Activity, Timestep).

intended_action(stop(Activity), Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_3_history(Activity, Timestep),
    futile(Activity, Timestep).

%--- Category 4 ---%
% "there is a goal g that is active in cm_n but no activity with goal g is active in cm_n"

existing_candidate(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    holds(next_name(M1), Timestep),
    Activity < M1,
    goal(Activity, G).

new_candidate(Activity, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    holds(next_name(Activity), Timestep).

candidate(Activity, Timestep) :-
    new_candidate(Activity, Timestep).

candidate(Activity, Timestep) :-
    existing_candidate(Activity, Timestep).

occurs(start(Activity), Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    candidate(Activity, Timestep),
    goal(Activity, G),
    not impossible(start(Activity), Timestep).

impossible(start(Activity), Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    goal(M1, G),
    occurs(start(M1), Timestep),
    Activity != M1.

:-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    occurs(start(Activity), Timestep),
    -projected_success(Activity, Timestep),
    not futile(G, Timestep).

{ apply_cr_rule(futile_goal(G, Timestep)) } :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    occurs(start(Activity), Timestep),
    -projected_success(Activity, Timestep).

futile(G, Timestep) :-
    apply_cr_rule(futile_goal(G, Timestep)).

:~
    apply_cr_rule(futile_goal(G, Timestep)). [1@1, futile_goal(G, Timestep)]

intended_action(wait, Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    futile(G, Timestep).

some_action_occurred(I1) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    Timestep <= I1,
    occurs(E, I1).

%--- Creating new candidates ---%

goal(Activity, G) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep).

{ apply_cr_rule(plan_new(PAA, I1)) } :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    Timestep < I1,
    some_action_occurred(I1 - 1).

occurs(PAA, I1) :-
    apply_cr_rule(plan_new(PAA, I1)).

:~
    apply_cr_rule(plan_new(PAA, I1)). [1@1, plan_new(PAA, I1)]

component(Activity, I1 - 1, PAA) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep),
    occurs(start(Activity)),
    occurs(PAA, I1).

:-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep),
    component(Activity, K, PAA1),
    component(Activity, K, PAA2),
    PAA1 != PAA2.

has_comp(Activity, K) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    component(Activity, K, C).

length(Activity, K) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    new_candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    has_comp(Activity, K),
    not has_comp(Activity, K + 1).

%--- Creating existing candidates ---%

{ apply_cr_rule(plan_existing(PAA, I1)) } :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    existing_candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    Timestep < I1,
    holds(next_action(Activity, PAA), I1),
    some_action_occurred(I1 - 1).

occurs(PAA, I1) :-
    apply_cr_rule(plan_existing(PAA, I1)).

:~
    apply_cr_rule(plan_existing(PAA, I1)). [1@1, plan_existing(PAA, I1)]

occurs(MAA, I1) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    existing_candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    Timestep < I1,
    holds(in_progress(Activity), I1),
    holds(next_action(Activity, MAA), I1).

intended_action(start(Activity), Timestep) :-
    current_step(Timestep),
    interpretation(UnobservedActions, Timestep),
    category_4_history(G, Timestep),
    candidate(Activity, Timestep),
    occurs(start(Activity), Timestep),
    projected_success(Activity, Timestep).

% prefer(plan_new(PAA, I1), futile_goal(G, Timestep)).
:~
    not apply_cr_rule(plan_new(PAA, I1)),
    apply_cr_rule(futile_goal(G, Timestep)). [1@2, plan_new(PAA, I1), futile_goal(G, Timestep)]

% prefer(plan_existing(PAA, I1), futile_goal(G, Timestep)).
:~
    not apply_cr_rule(plan_existing(PAA, I1)),
    apply_cr_rule(futile_goal(G, Timestep)). [1@2, plan_existing(PAA, I1), futile_goal(G, Timestep)]
