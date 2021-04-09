#include "util.lp".

% We satisfy a particular obl(Action) when occurs(Action) is true
obl_satisfied(obl(Action)) :-
    obl(Action),
    @is_positive(Action) = true,
    occurs(Action).

% We satisfy a particular obl(-Action) when occurs(Action) is not true
obl_satisfied(obl(-Action)) :-
    obl(-Action),
    @is_positive(Action) = true,
    not occurs(Action).

% Closed-world assumption:
%   If we cannot derive obl(Happening) to be satisfied, then it is not satisfied
-obl_satisfied(obl(Happening)) :-
    obl(Happening),
    not obl_satisfied(obl(Happening)).

% Compliant if for all obl(Happening), obl_satisfied(obl(Happening)) is true
obl_compliant :-
    obl_satisfied(obl(Happening)) : obl(Happening).

% Non-compliant if there exists obl(Happening) where obl_satisfied(obl(Happening)) is not true
-obl_compliant :-
    obl(Happening),
    not obl_satisfied(obl(Happening)).
