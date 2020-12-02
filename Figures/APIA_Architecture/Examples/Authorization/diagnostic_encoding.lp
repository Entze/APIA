% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

%%%% Awareness Axiom %%%%

holds(Fluent, TimeStep) | -holds(Fluent, TimeStep) :-
    fluent(inertial, Fluent),
    TimeStep = 0.

%%%% History-to-hypothesis Axiom %%%%

occurs(Action, TimeStep) :-
    happened(Action, TimeStep).

%%%% Reality Check Axioms %%%%

:-
    observed(Fluent, TimeStep),
    -holds(Fluent, TimeStep).

:-
    -observed(Fluent, TimeStep),
    holds(Fluent, TimeStep).
