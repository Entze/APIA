% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%% Inertial axiom %%%%
#program action_description.

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
#program action_description.

-holds(Fluent, TimeStep) :-
    fluent(defined, Fluent),
    step(TimeStep),
    not holds(Fluent, TimeStep).

%%%% Closed-world assumption for actions %%%%
#program action_description.

-occurs(Action, TimeStep) :-
    action(Action),
    step(TimeStep),
    not occurs(Action, TimeStep).
