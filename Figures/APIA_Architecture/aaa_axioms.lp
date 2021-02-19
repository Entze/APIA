%%%% Awareness Axiom %%%%

holds(Fluent, Timestep) | -holds(Fluent, Timestep) :-
    fluent(inertial, Fluent),
    Timestep = 0.
