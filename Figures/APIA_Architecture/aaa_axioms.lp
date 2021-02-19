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

%%%% Reality Check Axioms %%%%

:-
    observed(Fluent, Timestep),
    -holds(Fluent, Timestep).

:-
    -observed(Fluent, Timestep),
    holds(Fluent, Timestep).
