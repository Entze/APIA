% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%% Inertial axiom %%%%

step(TimeStep) :-
    TimeStep = 0..max_timestep.

holds(Fluent, TimeStep + 1) :-
    fluent(inertial, Fluent),
    step(TimeStep),
    holds(Fluent, TimeStep),
    not -holds(Fluent, TimeStep + 1),

-holds(Fluent, TimeStep + 1) :-
    fluent(inertial, Fluent),
    step(TimeStep),
    -holds(Fluent, TimeStep),
    not holds(Fluent, TimeStep + 1).

%%%% Closed-world assumption for defined fluents %%%%

-holds(Fluent, TimeStep) :-
    fluent(defined, Fluent),
    step(TimeStep),
    not holds(Fluent, TimeStep).

%%%% Closed-world assumption for actions %%%%

-occurs(Action, TimeStep) :-
    action(Action),
    step(TimeStep),
    not occurs(Action, TimeStep).
