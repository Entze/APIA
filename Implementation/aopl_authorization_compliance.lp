% TODO: Delete first half of file
#program aopl_compliance(current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Iff [for all occurs(Action, Timestep), permitted(Action, Timestep) is true],
%   then we are strongly compliant
%
% Inverse: Iff [there exists occurs(Action, Timestep), permitted(Action, Timestep) is not true],
%   then we are not strongly compliant
%
% Note: It is useful to differentiate between the compliance of past actions (i.e. our history)
%   with the compliance of the projection of future actions (i.e. our activity).
%   Without it, we cannot imagine being more compliant than our history.
-auth_compliance(history, strong) :-
    occurs(Action, Timestep),
    agent_action(Action),  % Note: Our addition
    Timestep < current_timestep,
    not permitted(Action, Timestep).

-auth_compliance(future, strong) :-
    occurs(Action, Timestep),
    agent_action(Action),  % Note: Our addition
    Timestep >= current_timestep,
    not permitted(Action, Timestep).

% Iff [for all occurs(Action, Timestep), permitted(Action, Timestep) is not false],
%   then we are weakly compliant
%
% Inverse: Iff [there exists occurs(Action, Timestep), permitted(Action, Timestep) is false],
%   then we are not weakly compliant
%
% Distinguish between past and future compliance
-auth_compliance(history, weak) :-
    occurs(Action, Timestep),
    agent_action(Action),  % Note: Our addition
    Timestep < current_timestep,
    -permitted(Action, Timestep).

-auth_compliance(future, weak) :-
    occurs(Action, Timestep),
    agent_action(Action),  % Note: Our addition
    Timestep >= current_timestep,
    -permitted(Action, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

auth_compliance(Type, weak) :-
    Type = (
        history;
        future
    ),
    not -auth_compliance(Type, weak).

auth_compliance(Type, strong) :-
    Type = (
        history;
        future
    ),
    not -auth_compliance(Type, strong).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sanity Checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aopl_sanity_check(timestep).
% Note: Our additions

% An authorizaiton policy can only describe agent actions (and wait)

:-
    permitted(Action, timestep),
    action(Action),
    Action != wait,
    not agent_action(Action).

:-
    -permitted(Action, timestep),
    action(Action),
    Action != wait,
    not agent_action(Action).
