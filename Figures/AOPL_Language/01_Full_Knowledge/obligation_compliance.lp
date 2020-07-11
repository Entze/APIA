obl_satisfied(obl(Action)) :-
    obl(Action),
    @is_positive(Action) = true,
    occurs(Action).

obl_satisfied(obl(-Action)) :-
    obl(-Action),
    @is_positive(Action) = true,
    not occurs(Action).

-obl_satisfied(obl(Happening)) :-
    obl(Happening),
    not obl_satisfied(Happening).

obl_compliant :-
    obl_satisfied(obl(Happening)) : obl(Happening).

-obl_compliant :-
    obl(Happening),
    not obl_satisfied(obl(Happening)).
