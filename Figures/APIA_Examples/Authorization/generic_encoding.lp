% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)

%%%% Inertial axiom %%%%
#program action_description(max_timestep).

step(TimeStep) :-
    TimeStep = 0..max_timestep.

holds(Fluent, TimeStep + 1) :-
    fluent(inertial, Fluent),
    step(TimeStep),
    holds(Fluent, TimeStep),
    not -holds(Fluent, TimeStep + 1),
    TimeStep < max_timestep.

-holds(Fluent, TimeStep + 1) :-
    fluent(inertial, Fluent),
    step(TimeStep),
    -holds(Fluent, TimeStep),
    not holds(Fluent, TimeStep + 1),
    TimeStep < max_timestep.

%%%% Closed-world assumption for defined fluents %%%%
#program action_description(max_timestep).

-holds(Fluent, TimeStep) :-
    fluent(defined, Fluent),
    step(TimeStep),
    not holds(Fluent, TimeStep).

%%%% Closed-world assumption for actions %%%%
#program action_description(max_timestep).

-occurs(Action, TimeStep) :-
    action(Action),
    step(TimeStep),
    not occurs(Action, TimeStep).

%%%% Misc %%%%
#program action_description(max_timestep).

-holds(neg(Fluent), TimeStep) :-
    fluent(_, Fluent),
    holds(Fluent, TimeStep).

-holds(Fluent, TimeStep) :-
    fluent(_, Fluent),
    holds(neg(Fluent), TimeStep).
