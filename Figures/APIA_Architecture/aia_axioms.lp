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
