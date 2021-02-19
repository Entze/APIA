% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%% Inertial axiom %%%%

step(Timestep) :-
    Timestep = 0..max_timestep.

holds(Fluent, Timestep + 1) :-
    fluent(inertial, Fluent),
    step(Timestep),
    holds(Fluent, Timestep),
    not -holds(Fluent, Timestep + 1).

-holds(Fluent, Timestep + 1) :-
    fluent(inertial, Fluent),
    step(Timestep),
    -holds(Fluent, Timestep),
    not holds(Fluent, Timestep + 1).

%%%% Closed-world assumption for defined fluents %%%%

-holds(Fluent, Timestep) :-
    fluent(defined, Fluent),
    step(Timestep),
    not holds(Fluent, Timestep).

%%%% Closed-world assumption for actions %%%%

-occurs(Action, Timestep) :-
    action(Action),
    step(Timestep),
    not occurs(Action, Timestep).
