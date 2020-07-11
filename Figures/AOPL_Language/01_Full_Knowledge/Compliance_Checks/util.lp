#script(python).
import clingo


def is_positive(symbol: clingo.Symbol) -> bool:
    return symbol.positive


def is_negative(symbol: clingo.Symbol) -> bool:
    return symbol.negative

#end.

#const true = 1.
#const false = 0.
