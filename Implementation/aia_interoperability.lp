%%%% Conversion to AIA %%%%

obs(Fluent, true, Timestep) :-
    observed(Fluent, Timestep).

obs(Fluent, false, Timestep) :-
    -observed(Fluent, Timestep).

hpd(Action, true, Timestep) :-
    happened(Action, Timestep).

hpd(Action, false, Timestep) :-
    -happened(Action, Timestep).
