#script(python)
import clingo

# TODO: Remove this file in favor of obl(neg(Action))


def is_positive(symbol: clingo.Symbol) -> bool:
    return symbol.positive


def is_negative(symbol: clingo.Symbol) -> bool:
    return symbol.negative

#end.

#const true = 1.
#const false = 0.
