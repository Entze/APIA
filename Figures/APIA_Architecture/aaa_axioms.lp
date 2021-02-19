% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

%%%% Awareness Axiom %%%%

holds(Fluent, Timestep) | -holds(Fluent, Timestep) :-
    fluent(inertial, Fluent),
    Timestep = 0.

%%%% Occurrence-Awareness Axiom %%%%

occurs(Action, Timestep) :-
    happened(Action, Timestep).

%%%% Initialization Axiom %%%%

holds(Fluent, Timestep) :-
    observed(Fluent, Timestep),
    Timestep = 0.

-holds(Fluent, Timestep) :-
    -observed(Fluent, Timestep),
    Timestep = 0.

%%%% Reality Check Axioms %%%%
#program aaa_reality_check(current_timestep).

:-
    observed(Fluent, Timestep),
    Timestep <= current_timestep,
    -holds(Fluent, Timestep).

:-
    -observed(Fluent, Timestep),
    Timestep <= current_timestep,
    holds(Fluent, Timestep).
