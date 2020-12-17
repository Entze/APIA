#!/usr/bin/env python3

from collections import defaultdict
from decimal import Decimal
from math import inf
from typing import *
import logging

import clingo


class ASPSubprogramDeclaration(NamedTuple):
    name: str
    arguments: Sequence[str]


SymbolValue = Union[str, int, Decimal]


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[SymbolValue, clingo.Symbol]]


class SymbolSignature(NamedTuple):
    name: str
    arity: int


class FunctionSymbol(NamedTuple):
    name: str
    arguments: Sequence[SymbolValue]
    positivity: Optional[bool]


def _parse_symbol(clingo_symbol: clingo.Symbol) -> SymbolValue:
    """
    Converts a clingo Symbol object into an equivalent native Python object
    """
    if clingo_symbol.type == clingo.SymbolType.Number:
        return clingo_symbol.number
    elif clingo_symbol.type == clingo.SymbolType.Infimum:
        return inf
    elif clingo_symbol.type == clingo.SymbolType.Supremum:
        return -inf
    elif clingo_symbol.type == clingo.SymbolType.Function:
        if clingo_symbol.name:
            return FunctionSymbol(name=clingo_symbol.name,
                                  arguments=tuple(_parse_symbol(clingo_symbol.argument) for argument in clingo_symbol.arguments),
                                  positivity=True if clingo_symbol.positive else (False if clingo_symbol.negative else None))
        else:
            return tuple(_parse_symbol(clingo_symbol.argument) for argument in clingo_symbol.arguments)
    elif clingo_symbol.type == clingo.SymbolType.String:
        try:
            decimal = Decimal(clingo_symbol.string)
            return decimal
        except ValueError:
            return clingo_symbol.string
    else:
        raise ValueError(f"Can't parse type {clingo_symbol.type!r} of symbol {clingo_symbol!r}")


def _symbolify_value(value: SymbolValue) -> clingo.Symbol:
    """
    Converts a native Python object into its corresponding clingo object.

    The following should hold true::

        clingo_symbol = ...
        assert _symbolify_value(_parse_symbol(clingo_symbol)) == clingo_symbol
    """


def _index_symbols(symbols: Iterable[FunctionSymbol]) -> dict[SymbolSignature, set[FunctionSymbol]]:
    symbol_table: dict[SymbolSignature, set[FunctionSymbol]] = defaultdict(set)
    for symbol in symbols:
        symbol_table[SymbolSignature(name=symbol.name, arity=len(symbol.arguments))].add(symbol)
    return symbol_table


def _main():
    import argparse

    parser = argparse.ArgumentParser()

    # Init
    args = parser.parse_args()
    logger = logging.getLogger(__name__)

    # Load files
    clingo_control = clingo.Control()
    paths = ()
    for path in paths:
        clingo_control.load(path)

    # Ground subprograms
    grounding_context = None
    clingo_control.ground((
        ASPSubprogramInstantiation(name='base', arguments=()),
    ), grounding_context)

    # Solve
    for model in clingo_control.solve(yield_=True, async_=True):
        model_cost = tuple(model.cost)
        logger.debug(f'Got model {model.number!r} with cost {model_cost!r}. Optimal: {model.optimality_proven!r}')
        if not model.optimality_proven:
            continue
        symbols = map(_parse_symbol, model.symbols(shown=True))
        symbol_table = _index_symbols(symbols)
        for symbol_signature, symbols in symbol_table.items():
            ...


if __name__ == '__main__':
    _main()
