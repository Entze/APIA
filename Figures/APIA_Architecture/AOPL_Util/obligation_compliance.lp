% Iff [for all obl(Action, TimeStep), occurs(Action, TimeStep) is true]
% and [for all obl(-Action, TimeStep), occurs(Action, TimeStep) is false],
%      then we are compliant
%
% Inverse:
% Iff [there exists obl(Action, TimeStep), occurs(Action, TimeStep) is not true]
%  or [there exists obl(Action, TimeStep), occurs(Action, TimeStep) is not false],
%      then we are not compliant
%
% Break apart:
% If [there exists obl(Action, TimeStep), occurs(Action, TimeStep) is not true],
%     then we are not compliant.
% If [there exists obl(Action, TimeStep), occurs(Action, TimeStep) is not false],
%     then we are not compliant.
-obl_compliant :-
    obl(Action, TimeStep),
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    not occurs(Aciton, TimeStep).

-obl_compliant :-
    obl(neg(Action), TimeStep),
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    not -occurs(Aciton, TimeStep).
