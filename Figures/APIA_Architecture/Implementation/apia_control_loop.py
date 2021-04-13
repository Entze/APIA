#!/usr/bin/env python3.9

import os
import sys
from collections import deque, defaultdict
from decimal import Decimal, DecimalException
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

    def __repr__(self):
        return f'{self.__class__.__name__}.{self.name}'


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

    def __repr__(self):
        return f'{self.__class__.__name__}.{self.name}'


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
    PERMIT_COMMISSIONS = frozenset((
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

    def __repr__(self):
        return f'{self.__class__.__name__}.{self.name}'


class APIAConfiguration(NamedTuple):
    authorization: APIAAuthorizationSetting
    obligation: APIAObligationSetting


class GroundingContext:
    @staticmethod
    def str_format(template_str: clingo.Symbol, *arguments: clingo.Symbol) -> str:
        template_str = template_str.string
        arguments = (symbol.string if symbol.type == clingo.SymbolType.String else symbol
                     for symbol in arguments)
        return template_str.format(*arguments)

    @staticmethod
    def function_signature(symbol: clingo.Symbol) -> str:
        return f'{symbol.name}/{len(symbol.arguments)}'


def generate_aia_subprograms_to_ground(current_timestep: int,
                                       max_timestep: int,
                                       step_number: AIALoopStep,
                                       configuration: APIAConfiguration,
                                       ) -> Iterator[ASPSubprogramInstantiation]:
    max_activity_length = max_timestep

    # base
    yield ASPSubprogramInstantiation(name='base', arguments=())

    # axioms(timestep)
    yield from (ASPSubprogramInstantiation(name='axioms', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # action_description(timestep)
    yield from (ASPSubprogramInstantiation(name='action_description', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # aia_mental_fluents(max_activity_length)
    yield ASPSubprogramInstantiation(name='aia_mental_fluents', arguments=(max_activity_length,))

    # aia_sanity_checks(current_timestep, max_activity_length)
    # aia_history_rules(current_timestep)
    if step_number >= 1:
        yield ASPSubprogramInstantiation(name='aia_sanity_checks', arguments=(current_timestep, max_activity_length))
        yield ASPSubprogramInstantiation(name='aia_history_rules', arguments=(current_timestep,))

    # aia_intended_action_rules(current_timestep, max_activity_length)
    if step_number >= 2:
        yield ASPSubprogramInstantiation(name='aia_intended_action_rules', arguments=(current_timestep, max_activity_length))

    # policy_description(timestep)
    yield from (ASPSubprogramInstantiation(name='policy_description', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # aopl_compliance(current_timestep)
    yield ASPSubprogramInstantiation(name='aopl_compliance', arguments=(current_timestep,))

    # aopl_sanity_check(timestep)
    yield from (ASPSubprogramInstantiation(name='aopl_sanity_check', arguments=(timestep,))
                for timestep in range(max_timestep + 1))

    # apia_action_description(current_timestep)
    yield ASPSubprogramInstantiation(name='apia_action_description', arguments=(current_timestep,))

    # apia_axioms(current_timestep)
    yield ASPSubprogramInstantiation(name='apia_axioms', arguments=(current_timestep,))

    # apia_show_terms(current_timestep)
    yield ASPSubprogramInstantiation(name='apia_show_terms', arguments=(current_timestep,))

    # apia_options
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.authorization.value))
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.obligation.value))


def _parse_symbol(clingo_symbol: Union[clingo.Symbol, Iterable[clingo.Symbol]]) -> SymbolValue:
    """
    Converts a clingo Symbol object into an equivalent native Python object
    """
    if not isinstance(clingo_symbol, clingo.Symbol):
        try:
            iterable = iter(clingo_symbol)
        except TypeError:
            return clingo_symbol
        else:
            return tuple(_parse_symbol(elem) for elem in iterable)

    if clingo_symbol.type == clingo.SymbolType.Number:
        return clingo_symbol.number
    elif clingo_symbol.type == clingo.SymbolType.Infimum:
        return inf
    elif clingo_symbol.type == clingo.SymbolType.Supremum:
        return -inf
    elif clingo_symbol.type == clingo.SymbolType.Function:
        if clingo_symbol.name:
            return FunctionSymbol(name=clingo_symbol.name,
                                  arguments=tuple(_parse_symbol(clingo_symbol.arguments) for argument in clingo_symbol.arguments),
                                  positivity=True if clingo_symbol.positive else (False if clingo_symbol.negative else None))
        else:
            return tuple(_parse_symbol(clingo_symbol.arguments) for argument in clingo_symbol.arguments)
    elif clingo_symbol.type == clingo.SymbolType.String:
        try:
            decimal = Decimal(clingo_symbol.string)
            return decimal
        except (ValueError, DecimalException):
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
                        predicate_signatures: Mapping[SymbolSignature, bool],
                        current_timestep: int) -> deque[clingo.Symbol]:
    if len(predicate_signatures) == 0:
        return deque()

    predicates: deque[clingo.Symbol] = deque()
    for symbol in model.symbols(shown=True):
        # Predicate extraction
        try:
            filter_by_timestep = predicate_signatures[symbol.name, len(symbol.arguments)]

        except KeyError:
            pass

        else:
            if filter_by_timestep:
                *_, timestep = map(_parse_symbol, symbol.arguments)
                if timestep == current_timestep:
                    predicates.append(symbol)
            else:
                predicates.append(symbol)

    return predicates


def _run_clingo(files: Iterable[Path],
                clingo_args: Iterable[str],
                assertions: Iterable[clingo.Symbol],
                observation_subprograms: Iterable[ASPSubprogramInstantiation],
                current_timestep: int,
                max_timestep: int,
                step_number: AIALoopStep,
                configuration: APIAConfiguration,
                output_predicates: Mapping[SymbolSignature, bool],
                debug: bool = False,
                ) -> Sequence[clingo.Symbol]:
    # Set up
    clingo_control = _init_clingo(files=files, clingo_args=clingo_args, assertions=assertions)
    subprograms_to_ground = chain(
        generate_aia_subprograms_to_ground(
            current_timestep=current_timestep,
            max_timestep=max_timestep,
            step_number=step_number,
            configuration=configuration),
        observation_subprograms)

    # Grounding
    print('    Grounding...')
    if debug == True:
        subprograms_to_ground = tuple(subprograms_to_ground)
        for subprogram in subprograms_to_ground:
            print(f'      {subprogram!r}', file=sys.stderr)
    clingo_control.ground(subprograms_to_ground, GroundingContext)

    # Solving
    print('    Solving...')
    solve_handle = clingo_control.solve(yield_=True, async_=True)
    symbols = ()

    stable_models = 0
    proven_optimal_stable_models = 0
    for model in solve_handle:  # type: clingo.Model
        if debug == True:
            print(f'    Model {model.number} (Proven optimal: {model.optimality_proven})', file=sys.stderr)
            for symbol in sorted(model.symbols(atoms=True)):
                print(f'      {symbol}', file=sys.stderr)

            if model.optimality_proven:
                proven_optimal_stable_models += 1
            else:
                stable_models += 1

        # Predicate extraction
        if model.number == 1:
            # Either first or first optimal
            symbols = _extract_predicates(
                model=model,
                current_timestep=current_timestep,
                predicate_signatures=output_predicates)

    solve_result = solve_handle.get()
    if not solve_result.satisfiable:
        raise RuntimeError('Solve is unsatisfiable')

    if debug:
        if proven_optimal_stable_models > 1 or (proven_optimal_stable_models == 0 and stable_models > 1):
            print('    Warning: Multiple answer sets', file=sys.stderr)


    return symbols


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
    parser.add_argument('--threads',
                        type=int,
                        required=False, default=os.cpu_count())
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
        script_dir / 'apia_show.lp',
        *map(Path, args.files),
    )
    clingo_args = (
        '--opt-mode=optN',
        '--parallel-mode', f'{args.threads}',
        '--warn=no-atom-undefined',
        '2' if debug else '1',
    )

    configuration = APIAConfiguration(authorization=args.authorization_mode,
                                      obligation=args.obligation_mode)
    print('Running with configuration:', configuration, file=sys.stderr)

    history: deque[clingo.Symbol] = deque()
    observation_subprograms: deque[ASPSubprogramInstantiation] = deque()
    # TODO: Run initial solve to find pre-existing activities and set ir value
    for current_timestep in range(max_timestep + 1):
        print(f'Iteration {current_timestep}')

        # Step 1: Interpret Observations
        print('  Step 1: Interpret observations')
        symbols = _run_clingo(
            files=clingo_files,
            clingo_args=clingo_args,
            assertions=history,
            observation_subprograms=observation_subprograms,
            current_timestep=current_timestep,
            max_timestep=max_timestep,
            configuration=configuration,
            step_number=AIALoopStep(1),
            output_predicates={
                SymbolSignature(name='number_unobserved', arity=2): True,
                SymbolSignature(name='diagnosis', arity=3): True,
            },
            debug=debug,
        )
        step_2_unobserved_actions: dict[int, deque] = defaultdict(deque)
        step_2_unobserved_actions_count = None
        for symbol in symbols:
            if symbol.name == 'number_unobserved' and len(symbol.arguments) == 2:
                step_2_unobserved_actions_count, _ = symbol.arguments
            elif symbol.name == 'diagnosis' and len(symbol.arguments) == 3:
                action, timestep, _ = symbol.arguments
                step_2_unobserved_actions[timestep].append(action)
            else:
                raise ValueError(f"I don't know how to display this symbol: {symbol}")
        assert step_2_unobserved_actions_count is not None, 'number_unobserved(x, n) is not present'
        print(f'    Unobserved actions: {step_2_unobserved_actions_count}')
        for timestep in sorted(step_2_unobserved_actions.keys()):
            for action in sorted(step_2_unobserved_actions[timestep]):
                print(f'      {clingo.Function("occurs", (action, timestep))}')

        # Step 2: Find intended action
        print()
        print('  Step 2: Find intended action')
        symbols = _run_clingo(
            files=clingo_files,
            clingo_args=clingo_args,
            assertions=chain(history, (
                clingo.Function('interpretation', (step_2_unobserved_actions_count, current_timestep)),
            )),
            observation_subprograms=observation_subprograms,
            current_timestep=current_timestep,
            max_timestep=max_timestep,
            configuration=configuration,
            step_number=AIALoopStep(2),
            output_predicates={
                SymbolSignature(name='intended_action', arity=2): True,
                SymbolSignature(name='futile_goal', arity=2): True,
                SymbolSignature(name='activity_component', arity=3): False,
                SymbolSignature(name='activity_length', arity=2): False,
                SymbolSignature(name='activity_goal', arity=2): False,
            },
            debug=debug,
        )
        try:
            futile_goal, = (symbol.arguments[0]
                            for symbol in symbols
                            if symbol.name == 'futile_goal' and len(symbol.arguments) == 2)
        except ValueError:
            pass
        else:
            print(f'    Futile goal: {futile_goal}')
        step_3_intended_actions = tuple(symbol.arguments[0]
                                        for symbol in symbols
                                        if symbol.name == 'intended_action' and len(symbol.arguments) == 2)
        for intended_action in step_3_intended_actions:
            print(f'    Intended action: {intended_action}')
        new_activity_symbols = tuple(filter(lambda symbol: symbol.name.startswith('activity_'), symbols))
        if len(new_activity_symbols) > 0:
            print(f'    New activity:')
        for symbol in new_activity_symbols:
            print(f'      {symbol}')
        # TODO: Save generated activity if intended action is start(M)

        # Step 3: Perform intended action
        print()
        print('  Step 3: Do intended action')
        for intended_action in step_3_intended_actions:
            print(f'    Doing {intended_action}')
            history.append(clingo.Function('attempt', (intended_action, current_timestep)))

        # Step 4: Observe world
        print()
        print('  Step 4: Observe world')
        print(f'    Getting observations from #program observations_{current_timestep + 1}.')
        observation_subprograms.append(ASPSubprogramInstantiation(name=f'observations_{current_timestep + 1}', arguments=()))
        if debug:
            _run_clingo(
                files=clingo_files,
                clingo_args=clingo_args,
                assertions=chain(history, (
                    clingo.Function('interpretation', (step_2_unobserved_actions_count, current_timestep)),
                )),
                observation_subprograms=observation_subprograms,
                current_timestep=current_timestep,
                max_timestep=max_timestep,
                configuration=configuration,
                step_number=AIALoopStep(4),
                output_predicates={},
                debug=debug,
            )

        print()


if __name__ == '__main__':
    script_dir = Path(__file__).resolve().parent
    _main(script_dir)
