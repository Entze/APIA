% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inertia axiom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program axioms(timestep).

holds(Fluent, timestep + 1) :-
    fluent(inertial, Fluent),
    holds(Fluent, timestep),
    not -holds(Fluent, timestep + 1).

-holds(Fluent, timestep + 1) :-
    fluent(inertial, Fluent),
    -holds(Fluent, timestep),
    not holds(Fluent, timestep + 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption for defined fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program axioms(timestep).

-holds(Fluent, timestep) :-
    fluent(defined, Fluent),
    not holds(Fluent, timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption for actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program axioms(timestep).

-occurs(Action, timestep) :-
    action(Action),
    not occurs(Action, timestep).
