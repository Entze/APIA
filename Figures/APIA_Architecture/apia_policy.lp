%%%% Authorization policy %%%%

% "An agent is always allowed to perform mental actions"
%
% permitted(MentalAction)
permitted(Action, Timestep) :-
    step(Timestep),
    mental_action(Action),
    agent_action(Action).
