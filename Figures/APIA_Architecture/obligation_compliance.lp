% We satisfy a particular obl(Action, TimeStep) when occurs(Action, TimeStep) is true
obl_satisfied(obl(Action, TimeStep)) :-
    obl(Action, TimeStep),
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    occurs(Action, TimeStep).

% We satisfy a particular obl(-Action, TimeStep) when occurs(Action, TimeStep) is not true
obl_satisfied(obl(-Action, TimeStep)) :-
    obl(-Action, TimeStep),
    action(Action),  % Note: action(Action) ensures is_positive(Action) = true.
    not occurs(Action, TimeStep).

% Closed-world assumption:
%   If we cannot derive obl(Happening) to be satisfied, then it is not satisfied
-obl_satisfied(obl(Happening, TimeStep)) :-
    obl(Happening, TimeStep),
    not obl_satisfied(obl(Happening, TimeStep)).

% Compliant if for all obl(Happening), obl_satisfied(obl(Happening)) is true
obl_compliant :-
    obl_satisfied(obl(Happening, TimeStep)) : obl(Happening, TimeStep).

% Non-compliant if there exists obl(Happening) where obl_satisfied(obl(Happening)) is not true
-obl_compliant :-
    obl(Happening, TimeStep),
    not obl_satisfied(obl(Happening, TimeStep)).
