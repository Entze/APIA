%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Awareness Axiom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

holds(Fluent, Timestep) | -holds(Fluent, Timestep) :-
    fluent(inertial, Fluent),
    Timestep = 0.
