#!/usr/bin/env python3

import os
import sys
from collections import deque
from decimal import Decimal
from enum import Enum, IntEnum
from itertools import chain
from math import inf
from pathlib import Path
from typing import *

import clingo


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[str, int]]


class SymbolSignature(NamedTuple):
    name: str
    arity: int


SymbolValue = Union[str, int, Decimal]


class FunctionSymbol(NamedTuple):
    name: str
    arguments: Sequence[SymbolValue]
    positivity: Optional[bool]


class AIALoopStep(IntEnum):
    INTERPRET_OBSERVATIONS = 1
    INTENDED_ACTION = 2
    ATTEMPT_ACTION = 3
    OBSERVE_WORLD = 4


class APIAAuthorizationSetting(Enum):
    PARANOID = frozenset((
        'apia_options_auth_weakly_compliant_1',
        'apia_options_auth_non_compliant_1',
    ))
    CAUTIOUS = frozenset((
        'apia_options_auth_weakly_compliant_2',
        'apia_options_auth_non_compliant_1',
        'apia_options_misc_2',
    ))
    SUBORDINATE = frozenset((
        'apia_options_auth_weakly_compliant_3',
        'apia_options_auth_non_compliant_1',
    ))
    BEST_EFFORT = frozenset((
        'apia_options_auth_weakly_compliant_2',
        'apia_options_auth_non_compliant_2',
        'apia_options_misc_2',
    ))
    SUBORDINATE_WHEN_POSSIBLE = frozenset((
        'apia_options_auth_weakly_compliant_3',
        'apia_options_auth_non_compliant_2',
        'apia_options_misc_2',
    ))
    UTILITARIAN = frozenset((
        'apia_options_auth_weakly_compliant_3',
        'apia_options_auth_non_compliant_3',
    ))


class APIAObligationSetting(Enum):
    SUBORDINATE = frozenset((
        'apia_options_obl_do_action_1',
        'apia_options_obl_refrain_from_action_1',
    ))
    PERMIT_OMISSIONS = frozenset((
        'apia_options_obl_do_action_2',
        'apia_options_obl_refrain_from_action_1',
        'apia_options_misc_2',
    ))
    PERMIT_COMISSIONS = frozenset((
        'apia_options_obl_do_action_1',
        'apia_options_obl_refrain_from_action_2',
        'apia_options_misc_2',
    ))
    BEST_EFFORT = frozenset((
        'apia_options_obl_do_action_2',
        'apia_options_obl_refrain_from_action_2',
        'apia_options_misc_2',
    ))
    UTILITARIAN = frozenset((
        'apia_options_obl_do_action_3',
        'apia_options_obl_refrain_from_action_3',
    ))


class APIAConfiguration(NamedTuple):
    authorization: APIAAuthorizationSetting
    obligation: APIAObligationSetting


class GroundingContext:
    @staticmethod
    def str_format(template_str: clingo.Symbol, *arguments: clingo.Symbol) -> str:
        template_str = template_str.string
        arguments = (symbol.string if symbol.type == clingo.SymbolType.String else symbol
                     for symbol in arguments)
        return template_str.format(*arguments).replace(' ', '_')

    @staticmethod
    def function_signature(symbol: clingo.Symbol) -> str:
        return f'{symbol.name}/{len(symbol.arguments)}'


def generate_aia_subprograms_to_ground(current_timestep: int,
                                        max_timestep: int,
                                        step_number: AIALoopStep,
                                        configuration: APIAConfiguration,
                                        ) -> Iterator[ASPSubprogramInstantiation]:
    # base
    yield ASPSubprogramInstantiation(name='base', arguments=())

    # axioms(timestep)
    yield from (ASPSubprogramInstantiation(name='axioms', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # action_description(timestep)
    yield from (ASPSubprogramInstantiation(name='action_description', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # aia_history_rules(timestep)
    if step_number >= 1:
        yield ASPSubprogramInstantiation(name='aia_history_rules', arguments=(current_timestep,))

    # aia_intended_action_rules(timestep, max_activity_length)
    max_activity_length = max_timestep
    if step_number >= 2:
        yield ASPSubprogramInstantiation(name='aia_intended_action_rules', arguments=(current_timestep, max_activity_length))

    # policy_description(timestep)
    yield from (ASPSubprogramInstantiation(name='policy_description', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # aopl_compliance
    yield ASPSubprogramInstantiation(name='aopl_compliance', arguments=(current_timestep,))

    # aopl_sanity_check(timestep)
    yield from (ASPSubprogramInstantiation(name='aopl_sanity_check', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # apia_action_description(timestep)
    yield ASPSubprogramInstantiation(name='apia_action_description', arguments=(current_timestep,))

    # apia_axioms(current_timestep)
    yield ASPSubprogramInstantiation(name='apia_axioms', arguments=(current_timestep,))

    # apia_options
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.authorization.value))
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.obligation.value))


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


def _init_clingo(files: Iterable[Path], clingo_args: Iterable[str], assertions: Iterable[clingo.Symbol]) -> clingo.Control:
    clingo_control = clingo.Control(clingo_args)
    for file in files:
        clingo_control.load(str(file))

    clingo_control.add('base', (), '\n'.join(f'{predicate}.' for predicate in assertions))

    return clingo_control


def _extract_predicates(model: clingo.Model,
                        predicate_signatures: Collection[SymbolSignature],
                        current_timestep: int,
                        debug=False) -> Deque[clingo.Symbol]:
    predicates: Deque[clingo.Symbol] = deque()
    for symbol in model.symbols(shown=True):
        # Predicate extraction
        if (symbol.name, len(symbol.arguments)) in predicate_signatures:
            *_, timestep = map(_parse_symbol, symbol.arguments)
            if timestep == current_timestep:
                predicates.append(symbol)

    if debug == True:
        print(f'    Model {model.number} (Proven optimal: {model.optimality_proven})', file=sys.stderr)
        for symbol in model.symbols(atoms=True):
            print(f'      {symbol}', file=sys.stderr)

    return predicates


def _main(script_dir: Path):
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('files', nargs='+',
                        help='ASP files')
    parser.add_argument('--max-timestep',
                        type=int, required=True,
                        help='Authorization policy seting')
    parser.add_argument('--authorization-mode',
                        type=lambda s: s.lower(), choices=tuple(setting.name.lower() for setting in APIAAuthorizationSetting),
                        required=True,
                        help='Authorization policy seting')
    parser.add_argument('--obligation-mode',
                        type=lambda s: s.lower(), choices=tuple(setting.name.lower() for setting in APIAObligationSetting),
                        required=True,
                        help='Obligation policy seting')
    parser.add_argument('--debug',
                        action='store_true',
                        help='Enable extra debugging output')

    args = parser.parse_args()
    args.authorization_mode = getattr(APIAAuthorizationSetting, args.authorization_mode.upper())
    args.obligation_mode = getattr(APIAObligationSetting, args.obligation_mode.upper())
    max_timestep: int = args.max_timestep
    debug: bool = args.debug

    clingo_files: Sequence[Path] = (
        script_dir / 'aaa_axioms.lp',
        script_dir / 'aia_theory_of_intentions.lp',
        script_dir / 'aia_history_rules.lp',
        script_dir / 'aia_intended_action_rules.lp',
        script_dir / 'aopl_authorization_compliance.lp',
        script_dir / 'aopl_obligation_compliance.lp',
        script_dir / 'general_axioms.lp',
        script_dir / 'apia_cr_prolog.lp',
        script_dir / 'apia_policy.lp',
        script_dir / 'apia_compliance_check.lp',
        *map(Path, args.files),
    )
    clingo_args = (
        '--opt-mode=optN',
        '--parallel-mode', f'{os.cpu_count()}',
        '--warn=no-atom-undefined',
        '1',
    )

    configuration = APIAConfiguration(authorization=args.authorization_mode,
                                      obligation=args.obligation_mode)
    print('Running with configuration:', configuration, file=sys.stderr)

    history: Deque[clingo.Symbol] = deque()
    observation_subprograms: Deque[ASPSubprogramInstantiation] = deque()
    for current_timestep in range(max_timestep + 1):
        # Step 1: Interpret Observations
        print(f'Step {current_timestep}.1: Interpret observations', file=sys.stderr)

        # Set up
        clingo_control = _init_clingo(files=clingo_files, clingo_args=clingo_args, assertions=history)
        subprograms_to_ground = chain(
            generate_aia_subprograms_to_ground(current_timestep, max_timestep, AIALoopStep(1), configuration),
            observation_subprograms)

        # Grounding
        print('  Grounding...', file=sys.stderr)
        if debug == True:
            subprograms_to_ground = tuple(subprograms_to_ground)
            for subprogram in subprograms_to_ground:
                print(f'    {subprogram!r}', file=sys.stderr)
        clingo_control.ground(subprograms_to_ground, GroundingContext)

        # Solving
        print('  Solving...', file=sys.stderr)
        solve_handle = clingo_control.solve(yield_=True, async_=True)
        for model in solve_handle:  # type: clingo.Model
            # Predicate extraction
            if model.number == 1:  # Either first or first optimal
                symbol, = _extract_predicates(model=model, current_timestep=current_timestep, debug=debug, predicate_signatures=(
                    SymbolSignature(name='number_unobserved', arity=2),
                ))
                step_2_unobserved_actions, _ = symbol.arguments
        solve_result = solve_handle.get()
        if not solve_result.satisfiable:
            raise RuntimeError('Solve is unsatisfiable')

        # Step 2: Find intended action
        print(file=sys.stderr)
        print(f'Step {current_timestep}.2: Find intended action', file=sys.stderr)

        # Set up
        clingo_control = _init_clingo(files=clingo_files, clingo_args=clingo_args, assertions=chain(history, (
            clingo.Function('interpretation', (step_2_unobserved_actions, current_timestep)),
        )))
        subprograms_to_ground = generate_aia_subprograms_to_ground(current_timestep, max_timestep, AIALoopStep(2),
                                                                   configuration)
        # Grounding
        print('  Grounding...', file=sys.stderr)
        if debug == True:
            subprograms_to_ground = tuple(subprograms_to_ground)
            for subprogram in subprograms_to_ground:
                print(f'    {subprogram!r}', file=sys.stderr)
        clingo_control.ground(subprograms_to_ground, GroundingContext)

        # Solving
        print('  Solving...', file=sys.stderr)
        step_3_intended_actions: Deque[clingo.Symbol] = deque()
        solve_handle = clingo_control.solve(yield_=True, async_=True)
        for model in solve_handle:  # type: clingo.Model
            # Predicate extraction
            if model.number == 1:  # Either first or first optimal
                symbols = _extract_predicates(model=model, current_timestep=current_timestep, debug=debug, predicate_signatures=(
                    SymbolSignature(name='intended_action', arity=2),
                ))
                step_3_intended_actions.extend(symbol.arguments[0]
                                               for symbol in symbols)
        solve_result = solve_handle.get()
        if not solve_result.satisfiable:
            raise RuntimeError('Solve is unsatisfiable')

        # Step 3: Perform intended action
        print(file=sys.stderr)
        print(f'Step {current_timestep}.3: Do intended action', file=sys.stderr)
        for intended_action in step_3_intended_actions:
            print(f'  Doing {intended_action}', file=sys.stderr)
            history.append(clingo.Function('attempt', (intended_action, current_timestep)))

        # Step 4: Observe world
        print(file=sys.stderr)
        print(f'Step {current_timestep}.4: Observe world', file=sys.stderr)
        print(f'  Getting observations from #program observations_{current_timestep + 1}.', file=sys.stderr)
        observation_subprograms.append(ASPSubprogramInstantiation(name=f'observations_{current_timestep + 1}', arguments=()))

        print(file=sys.stderr)


if __name__ == '__main__':
    script_dir = Path(__file__).resolve().parent
    _main(script_dir)
