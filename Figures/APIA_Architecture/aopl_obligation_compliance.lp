#program base.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% An obligation policy cannot be contradictory

-obl(neg(Action), Timestep) :-
    obl(Action, Timestep),
    action(Action).

-obl(Action, Timestep) :-
    obl(neg(Action), Timestep),
    action(Action).

% If an agent is obligated to perform an action,
% the action must be at least weakly compliant with its authorization policy
:-
    action(Action),
    obl(Action, Timestep),
    -permitted(Action, Timestep).

% If an agent is obligated to abstain from an action,
% the action cannot be explicitly permitted under its authorization policy
:-
    action(Action),
    obl(neg(Action), Timestep),
    permitted(Action, Timestep).
