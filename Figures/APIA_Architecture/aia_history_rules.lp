% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

%%%% Occurrence-Awareness Axiom %%%%
#program aia_axioms(current_timestep).

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    happened(Action, Timestep).

-occurs(Action, Timestep) :-
    Timestep < current_timestep,
    -happened(Action, Timestep).

%%%% Initialization Axiom %%%%
#program base.

holds(Fluent, Timestep) :-
    observed(Fluent, Timestep),
    Timestep = 0.

-holds(Fluent, Timestep) :-
    -observed(Fluent, Timestep),
    Timestep = 0.

%%%% Reality Check Axioms %%%%
#program aia_axioms(current_timestep).

:-
    observed(Fluent, Timestep),
    Timestep <= current_timestep,
    -holds(Fluent, Timestep).

:-
    -observed(Fluent, Timestep),
    Timestep <= current_timestep,
    holds(Fluent, Timestep).

%%%% Misc %%%%

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

:-
    Timestep < current_timestep,
    agent_action(Action),
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

%%%% Model rules %%%%

{ apply_cr_rule(diagnosis(Action, Timestep, current_timestep)) } :-
    step(Timestep),
    physical_action(Action),
    exogenous_action(Action),
    Timestep < current_timestep.

occurs(Action, Timestep) :-
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).

:~
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).
    [1@1, diagnosis(Action, Timestep, current_timestep)]

%%%%

unobserved(Action, Timestep) :-
    Timestep < current_timestep,
    physical_action(Action),  % TODO: In paper, but not AIA
    exogenous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, current_timestep) :-
    UnobservedActions = #count{ Action : unobserved(Action, current_timestep) }.
