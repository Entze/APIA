#script(python)
import clingo


def add(a: clingo.Symbol, b: clingo.Symbol) -> int:
    return a.number + b.number

#end.

a(@add(1, 2)).
