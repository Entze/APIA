%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Awareness Axiom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

holds(Fluent, Timestep) | -holds(Fluent, Timestep) :-
    fluent(inertial, Fluent),
    Timestep = 0.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Reality Check Axioms %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_history_rules(current_timestep).
%
% "[these] axioms guarantee the agent's observations do not contradict his expectations."
% (p. 58) of dissertation

% (p. 58) of dissertation
:-
    observed(Fluent, Timestep),
    Timestep <= current_timestep,
    -holds(Fluent, Timestep).

% (p. 58) of dissertation
:-
    -observed(Fluent, Timestep),
    Timestep <= current_timestep,
    holds(Fluent, Timestep).
