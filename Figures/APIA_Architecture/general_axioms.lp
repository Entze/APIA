% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%% Inertia axiom %%%%
#program axioms(timestep).

step(timestep) :-
    timestep = 0..max_timestep.

holds(Fluent, timestep + 1) :-
    fluent(inertial, Fluent),
    step(timestep),
    holds(Fluent, timestep),
    not -holds(Fluent, timestep + 1).

-holds(Fluent, timestep + 1) :-
    fluent(inertial, Fluent),
    step(timestep),
    -holds(Fluent, timestep),
    not holds(Fluent, timestep + 1).

%%%% Closed-world assumption for defined fluents %%%%

-holds(Fluent, timestep) :-
    fluent(defined, Fluent),
    step(timestep),
    not holds(Fluent, timestep).

%%%% Closed-world assumption for actions %%%%

-occurs(Action, timestep) :-
    action(Action),
    step(timestep),
    not occurs(Action, timestep).
