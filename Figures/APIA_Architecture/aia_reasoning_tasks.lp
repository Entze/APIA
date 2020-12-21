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

number_unobserved(N, Timestep) :-
    current_step(Timestep),
    N = #count{ unobserved(EX, IX) }.

%%%% Step 2 %%%%
#program aia_step_2.

:-
    current_step(Timestep),
    number_unobserved(N, Timestep),
    interpretation(X, Timestep),
    N != X.

%--- Category 1 ---%
% "there are no activities or goals that are active in cm_n"

category_1_history(Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    not active_goal_or_activity(Timestep).

active_goal_or_activity(Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    holds(active_goal(G), Timestep).

active_goal_or_activity(Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    holds(active(M), Timestep).

intended_action(wait, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_1_history(Timestep).

%--- Category 2 ---%
% "there is an activity m such that m is top-level and active in cm_n but its goal g is no longer active in cm_n"

category_2_history(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    -holds(minor(M), Timestep),
    holds(active(M), Timestep),
    goal(M, G),
    -active_goal(G).

intended_action(stop(M), Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_2_history(M, Timestep).

%--- Category 3 ---%
% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cm_n"

category_3_history(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    -holds(minor(M) Timestep),

occurs(Action, I1) :-
    current_step(Timestep),
    category_3_history(M, Timestep),
    interpretation(N, Timestep),
    Timestep <= I1,
    -holds(minor(M), I1),
    holds(in_progress(M), I1),
    holds(next_action(M, Action), I1),
    not impossible(Action, I1).

projected_success(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    -holds(minor(M), Timestep),
    Timestep < I1,
    holds(active(M), I1),
    goal(M, G),
    holds(G, I1).

-projected_success(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    not projected_success(M, Timestep).

intended_action(Action, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_3_history(M, Timestep),
    holds(next_action(M, Action), Timestep),
    projected_success(M, Timestep).

{ apply_cr_rule(f(M, Timestep)) } :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_3_history(M, Timestep),
    -projected_success(M, Timestep).

futile(M, Timestep) :-
    apply_cr_rule(f(M, Timestep)).

:~
    apply_cr_rule(f(M, Timestep)). [1@1, f(M, Timestep)]

:-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_3_history(M, Timestep),
    -projected_success(M, Timestep).

intended_action(stop(M), Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_3_history(M, Timestep),
    futile(M, Timestep).

%--- Category 4 ---%
% "there is a goal g that is active in cm_n but no activity with goal g is active in cm_n"

existing_candidate(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    holds(next_name(M1), Timestep),
    M < M1,
    goal(M, G).

new_candidate(M, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    holds(next_name(M), Timestep).

candidate(M, Timestep) :-
    new_candidate(M, Timestep).

candidate(M, Timestep) :-
    existing_candidate(M, Timestep).

occurs(start(M), Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    candidate(M, Timestep),
    goal(M, G),
    not impossible(start(M), Timestep).

impossible(start(M), Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    goal(M1, G),
    occurs(start(M1), Timestep),
    M != M1.

:-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    occurs(start(M), Timestep),
    -projected_success(M, Timestep),
    not futile(G, Timestep).

{ apply_cr_rule(futile_goal(G, Timestep)) } :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    occurs(start(M), Timestep),
    -projected_success(M, Timestep).

futile(G, Timestep) :-
    apply_cr_rule(futile_goal(G, Timestep)).

:~
    apply_cr_rule(futile_goal(G, Timestep)). [1@1, futile_goal(G, Timestep)]

intended_action(wait, Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    futile(G, Timestep).

some_action_occurred(I1) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    Timestep <= I1,
    occurs(E, I1).

%--- Creating new candidates ---%

goal(M, G) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep).

{ apply_cr_rule(plan_new(PAA, I1)) } :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep),
    occurs(start(M), Timestep),
    Timestep < I1,
    some_action_occurred(I1 - 1).

occurs(PAA, I1) :-
    apply_cr_rule(plan_new(PAA, I1)).

:~
    apply_cr_rule(plan_new(PAA, I1)). [1@1, plan_new(PAA, I1)]

component(M, I1 - 1, PAA) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep),
    occurs(start(M)),
    occurs(PAA, I1).

:-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep),
    component(M, K, PAA1),
    component(M, K, PAA2),
    PAA1 != PAA2.

has_comp(M, K) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep),
    occurs(start(M), Timestep),
    component(M, K, C).

length(M, K) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    new_candidate(M, Timestep),
    occurs(start(M), Timestep),
    has_comp(M, K),
    not has_comp(M, K + 1).

%--- Creating existing candidates ---%

{ apply_cr_rule(plan_existing(PAA, I1)) } :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    existing_candidate(M, Timestep),
    occurs(start(M), Timestep),
    Timestep < I1,
    holds(next_action(M, PAA), I1),
    some_action_occurred(I1 - 1).

occurs(PAA, I1) :-
    apply_cr_rule(plan_existing(PAA, I1)).

:~
    apply_cr_rule(plan_existing(PAA, I1)). [1@1, plan_existing(PAA, I1)]

occurs(MAA, I1) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    existing_candidate(M, Timestep),
    occurs(start(M), Timestep),
    Timestep < I1,
    holds(in_progress(M), I1),
    holds(next_action(M, MAA), I1).

intended_action(start(M), Timestep) :-
    current_step(Timestep),
    interpretation(N, Timestep),
    category_4_history(G, Timestep),
    candidate(M, Timestep),
    occurs(start(M), Timestep),
    projected_success(M, Timestep).

% prefer(plan_new(PAA, I1), futile_goal(G, Timestep)).
:~
    not apply_cr_rule(plan_new(PAA, I1)),
    apply_cr_rule(futile_goal(G, Timestep)). [1@2, plan_new(PAA, I1), futile_goal(G, Timestep)]

% prefer(plan_existing(PAA, I1), futile_goal(G, Timestep)).
:~
    not apply_cr_rule(plan_existing(PAA, I1)),
    apply_cr_rule(futile_goal(G, Timestep)). [1@2, plan_existing(PAA, I1), futile_goal(G, Timestep)]
