#program base.

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

-obl_compliant(Timestep) :-
    obl(Action, Timestep),
    agent_action(Action),  % Note: Our modification
    not occurs(Action, Timestep).

-obl_compliant(Timestep) :-
    obl(neg(Action), Timestep),
    agent_action(Action),
    not -occurs(Action, Timestep).

-obl_compliant :-
    -obl_compliant(_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obl_compliant(Timestep) :-
    step(Timestep),
    not -obl_compliant(Timestep).

obl_compliant :-
    not -obl_compliant.

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
