% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"
% and Blount. 2013. "An architecture for intentional agents"

%%%% Step 1 %%%%
#program aia_step_1.

occurs(A, I) :-
    current_step(I1),
    I < I1,
    attempt(A, I),
    not impossible(A, I).

:-
    current_step(I1),
    I < I1,
    occurs(A, I),
    not attempt(A, I).

-occurs(A, I) :-
    current_step(I1),
    I < I1,
    -hpd(A, I).

{ apply_cr_rule(d(A, I2)) } :-
    current_step(I1),
    physical_exogeneous_action(A),
    I2 < I1.

occurs(A, I2) :-
    apply_cr_rule(d(A, I2)).

:~
    apply_cr_rule(_). [1]

unobs(A, I) :-
    current_step(I1),
    I < I1,
    physical_exogeneous_action(A),
    occurs(A, I),
    not hpd(A, I).

number_unobs(N, I) :-
    current_step(I),
    N = #count{ unobs(EX, IX) }.

%%%% Step 2 %%%%
#program aia_step_2.

:-
    current_step(I),
    number_unobs(N, I),
    interpretation(X, I),
    N != X.

% "there are no activities or goals that are active in cmn"
category_1_history(I) :-
    current_step(I),
    interpretation(N, I),
    not active_goal_or_activity(I).

active_goal_or_activity(I) :-
    current_step(I),
    interpretation(N, I),
    h(active_goal(G), I).

active_goal_or_activity(I) :-
    current_step(I),
    interpretation(N, I),
    h(active(M), I).

intended_action(wait, I) :-
    current_step(I),
    interpretation(N, I),
    category_1_history(I).

% "there is an activity m such that m is top-level and active in cmn but its goal g is no longer active in cmn"
category_2_history(M, I) :-
    current_step(I),
    interpretation(N, I),
    -h(minor(M), I),
    h(active(M), I),
    goal(M, G),
    -active_goal(G).

intended_action(stop(M), I) :-
    current_step(I),
    interpretation(N, I),
    category_2_history(M, I).

% "there is an activity m such that m and its goal g are both top-level and active and a is the next action of m in cmn"
category_3_history(M, I) :-
    current_step(I),
    interpretation(N, I),
    -h(minor(M) I),

occurs(A, I1) :-
    current_step(I),
    category_3_history(M, I),
    interpretation(N, I),
    I <= I1,
    -h(minor(M), I1),
    h(in_progress(M), I1),
    h(next_action(M, A), I1),
    not impossible(A, I1).

projected_success(M, I) :-
    current_step(I),
    interpretation(N, I),
    -h(minor(M), I),
    I < I1,
    h(active(M), I1),
    goal(M, G),
    h(G, I1).

-projected_success(M, I) :-
    current_step(I),
    interpretation(N, I),
    not projected_success(M, I).

intended_action(A, I) :-
    current_step(I),
    interpretation(N, I),
    category_3_history(M, I),
    h(next_action(M, A), I),
    projected_success(M, I).

{ apply_cr_rule(f(M, I)) } :-
    current_step(I),
    interpretation(N, I),
    category_3_history(M, I),
    -projected_success(M, I).

futile(M, I) :-
    apply_cr_rule(f(M, I)).

:~
    apply_cr_rule(_). [1]

:-
    current_step(I),
    interpretation(N, I),
    category_3_history(M, I),
    -projected_success(M, I).

intended_action(stop(M), I) :-
    current_step(I),
    interpretation(N, I),
    category_3_history(M, I),
    futile(M, I).

% "there is a goal g that is active in cmn but no activity with goal g is active in cmn"

% TODO: Include category_4_history
