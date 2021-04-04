%%%% Authorization policy %%%%
#program policy_description(timestep).

% "An agent is always allowed to wait"
%
% permitted(wait)
permitted(Action, timestep) :-
    Action = wait.

% "An agent is always allowed to perform mental actions"
%
% permitted(MentalAction)
permitted(Action, timestep) :-
    mental_action(Action),
    agent_action(Action).
