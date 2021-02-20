% See p. 57 of dissertation

% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

#program aia_history_rules(current_timestep).

comp(PAA) :-
    physical_action(PAA),
    agent_action(PAA).

comp(M) :-
    activity(M).

equal(M, M1) :-
    activity(M),
    goal(M, G),
    goal(M1, G),
    equal_plan(M, M1).

equal_plan(M, M1) :-
    activity(M),
    length(M, L),
    length(M1, L),
    not different_component(M, M1).

different_component(M, M1) :-
    activity(M),
    component(M, K, C),
    component(M1, K, C1),
    C != C1.

:-
    activity(M),
    equal(M, M1),
    M != M1.

%%%% Initialization Axiom %%%%
%
% See p. 58 of dissertation
#program base.

holds(Fluent, Timestep) :-
    observed(Fluent, Timestep),
    Timestep = 0.

-holds(Fluent, Timestep) :-
    -observed(Fluent, Timestep),
    Timestep = 0.

%%%% Reality Check Axioms %%%%
%
% See p. 58 of dissertation
#program aia_history_rules(current_timestep).

:-
    observed(Fluent, Timestep),
    Timestep <= current_timestep,
    -holds(Fluent, Timestep).

:-
    -observed(Fluent, Timestep),
    Timestep <= current_timestep,
    holds(Fluent, Timestep).

%%%% Occurrence-Awareness Axiom %%%%
%
% See p. 58 of dissertation
#program aia_history_rules(current_timestep).

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    happened(Action, Timestep).

-occurs(Action, Timestep) :-
    Timestep < current_timestep,
    -happened(Action, Timestep).

%%%% Misc %%%%
%
% See p. 59 of dissertation

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

:-
    Timestep < current_timestep,
    agent_action(Action),
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

%%%% Pre-model rules %%%%
%
% See p. 59 of dissertation

impossible(select(G), I) :-
    I < current_timestep,
    occurs(select(G1), I),
    G != G1.

impossible(select(G), I) :-
    I < current_timestep,
    activity(M),
    holds(active(M), I).

impossible(select(G), I) :-
    I < current_timestep,
    holds(active_goal(G), I).

%%%%
%
% See p. 60 of dissertation

holds(status(M, -1), Timestep) :-
    activity(M),
    Timestep = 0.

-holds(active_goal(G), Timestep) :-
    Timestep = 0.

holds(next_name(ir), Timestep) :-
    Timestep = 0.

%%%% Applicability constraints %%%%
%
% "the agent always observes the results of
%   - his attempts to perform actions,
%   - occurrences of actions performed by his controller,
%   - the truth value of his goal."
% (p. 60) of dissertation

observed_result(AA, I) :-
    I <= current_timestep,
    happened(AA, B, I).

:-
    I <= current_timestep,
    attempt(AA, I),
    not observed_result(AA, I).

:-
    I < current_timestep,
    occurs(select(G), I),
    not happened(select(G), I).

:-
    I < current_timestep,
    occurs(abandon(G), I),
    not happened(abandon(G), I).

need_to_observe_goal(G, I) :-
    I <= current_timestep,
    % -holds(minor(G), I - 1),  % From AIA implementation
    holds(active_goal(G), I - 1).

need_to_observe_goal(G1, I) :-
    I <= current_timestep,
    goal(M1, G1),
    holds(immediate_child_goal(G1, G), I),
    holds(active_goal(G), I).

observed_goal(G, I) :-
    I <= current_timestep,
    observed(G, B, I).

:-
    I <= current_timestep,
    need_to_observe_goal(G, I),
    not observed_goal(G, I).

%%%% Model rules %%%%
%
% See p. 61 of dissertation

{ apply_cr_rule(diagnosis(Action, Timestep, current_timestep)) } :-
    Timestep = 0..current_timestep,
    physical_action(Action),
    exogenous_action(Action),
    Timestep < current_timestep.

occurs(Action, Timestep) :-
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).

:~
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).
    [1@1, diagnosis(Action, Timestep, current_timestep)]

%%%%
%
% See p. 62 of dissertation

unobserved(Action, Timestep) :-
    Timestep < current_timestep,
    physical_action(Action),  % TODO: In paper, but not AIA
    exogenous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, current_timestep) :-
    UnobservedActions = #count{ Action : unobserved(Action, current_timestep) }.
