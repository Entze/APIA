#script(python).
import clingo


def is_positive(symbol: clingo.Symbol) -> bool:
    return symbol.positive


def is_negative(symbol: clingo.Symbol) -> bool:
    return symbol.negative

#end.

#const true = 1.
#const false = 0.

% For all obl(A), require occurs(A).
:-
    obl(Action),
    @is_positive(Action) = true,
    not occurs(Action).

% For all obl(-A), require -occurs(A).
:-
    obl(-Action),
    @is_positive(Action) = true,
    not -occurs(Action).
