#include "util.lp".

% We satisfy a particular obl(Action, I) when occurs(Action, I) is true
obl_satisfied(obl(Action, I)) :-
    obl(Action, I),
    @is_positive(Action) = true,
    occurs(Action, I).

% We satisfy a particular obl(-Action, I) when occurs(Action, I) is not true
obl_satisfied(obl(-Action, I)) :-
    obl(-Action, I),
    @is_positive(Action) = true,
    not occurs(Action, I).

% Closed-world assumption:
%   If we cannot derive obl(Happening) to be satisfied, then it is not satisfied
-obl_satisfied(obl(Happening, I)) :-
    obl(Happening, I),
    not obl_satisfied(obl(Happening, I)).

% Compliant if for all obl(Happening), obl_satisfied(obl(Happening)) is true
obl_compliant :-
    obl_satisfied(obl(Happening, I)) : obl(Happening, I).

% Non-compliant if there exists obl(Happening) where obl_satisfied(obl(Happening)) is not true
-obl_compliant :-
    obl(Happening, I),
    not obl_satisfied(obl(Happening, I)).
