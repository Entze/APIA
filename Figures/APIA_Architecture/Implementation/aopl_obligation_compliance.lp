% TODO: Delete first half of file
#program aopl_compliance(current_timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Note: Our implementation based on formal defintion
% Note: action(Action) ensures is_positive(Action) = true.

% Iff [for all obl(Action, Timestep), occurs(Action, Timestep) is true]
% and [for all obl(-Action, Timestep), occurs(Action, Timestep) is false],
%      then we are compliant
%
% Inverse:
% Iff [there exists obl(Action, Timestep), occurs(Action, Timestep) is not true]
%  or [there exists obl(Action, Timestep), occurs(Action, Timestep) is not false],
%      then we are not compliant
%
% Break apart:
% If [there exists obl(Action, Timestep), occurs(Action, Timestep) is not true],
%     then we are not compliant.
% If [there exists obl(Action, Timestep), occurs(Action, Timestep) is not false],
%     then we are not compliant.
%
% Note: It is useful to differentiate between the compliance of past actions (i.e. our history)
%   with the compliance of the projection of future actions (i.e. our activity).
%   Without it, we cannot imagine being more compliant than our history.

-obl_compliant(history, do_action) :-
    obl(Action, Timestep),
    agent_action(Action),  % Note: Our modification
    Timestep < current_timestep,
    not occurs(Action, Timestep).

-obl_compliant(future, do_action) :-
    obl(Action, Timestep),
    agent_action(Action),  % Note: Our modification
    Timestep >= current_timestep,
    not occurs(Action, Timestep).

-obl_compliant(history, refrain_from_action) :-
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep < current_timestep,
    not -occurs(Action, Timestep).

-obl_compliant(future, refrain_from_action) :-
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    not -occurs(Action, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obl_compliant(Type, do_action) :-
    Type = (
        history;
        future
    ),
    not -obl_compliant(Type, do_action).

obl_compliant(Type, refrain_from_action) :-
    Type = (
        history;
        future
    ),
    not -obl_compliant(Type, refrain_from_action).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sanity Checks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aopl_sanity_check(timestep).
% Note: Our additions

% An obligation policy can only describe agent actions (and wait)

:-
    obl(Action, timestep),
    action(Action),
    Action != wait,
    not agent_action(Action).

:-
    obl(neg(Action), timestep),
    action(Action),
    Action != wait,
    not agent_action(Action).

% An obligation policy cannot be contradictory

-obl(neg(Action), timestep) :-
    obl(Action, timestep),
    action(Action).

-obl(Action, timestep) :-
    obl(neg(Action), timestep),
    action(Action).

% If an agent is obligated to perform an action,
% the action must be at least weakly compliant with its authorization policy
:-
    action(Action),
    obl(Action, timestep),
    -permitted(Action, timestep).

% If an agent is obligated to abstain from an action,
% the action cannot be explicitly permitted under its authorization policy
:-
    action(Action),
    obl(neg(Action), timestep),
    permitted(Action, timestep).
