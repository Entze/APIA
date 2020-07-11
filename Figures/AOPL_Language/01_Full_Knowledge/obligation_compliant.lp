#script(python).
import clingo


def is_positive(symbol: clingo.Symbol) -> bool:
    return symbol.positive


def is_negative(symbol: clingo.Symbol) -> bool:
    return symbol.negative

#end.

#const true = 1.
#const false = 0.

obl_satisfied(obl(Action)) :-
    obl(Action),
    @is_positive(Action) = true,
    occurs(Action).

obl_satisfied(obl(-Action)) :-
    obl(-Action),
    @is_positive(Action) = true,
    not occurs(Action).

-obl_satisfied(obl(Action)) :-
    obl(Action),
    not obl_satisfied(Action).

-obl_satisfied :-
    obl_satisfied(_).

obl_satisfied :-
    not -obl_satisfied.

:-
    obl_satisfied.
