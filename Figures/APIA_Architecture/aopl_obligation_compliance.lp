#program base.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Definition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    not occurs(Action, Timestep).

-obl_compliant(Timestep) :-
    obl(neg(Action), Timestep),
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    not -occurs(Action, Timestep).

-obl_compliant :-
    -obl_compliant(_).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Closed-world assumption %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

obl_compliant(Timestep) :-
    step(Timestep),
    not -obl_compliant(Timestep).

obl_compliant :-
    not -obl_compliant.
