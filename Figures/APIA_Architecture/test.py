#script(python)
# See p. 74 of dissertation for AIA control loop

from enum import Enum, IntEnum
from itertools import chain
from typing import *

import clingo


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[str, int]]


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


def str_format(template_str: clingo.Symbol, *arguments: clingo.Symbol) -> str:
    template_str = template_str.string
    arguments = (symbol.string if symbol.type == clingo.SymbolType.String else symbol
                 for symbol in arguments)
    return template_str.format(*arguments)


def function_signature(symbol: clingo.Symbol) -> str:
    return f'{symbol.name}/{len(symbol.arguments)}'


def _generate_aia_subprograms_to_ground(current_timestep: int,
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
    yield from (ASPSubprogramInstantiation(name='apia_action_description', arguments=(timestep,))
                for timestep in range(current_timestep, max_timestep + 1))

    # apia_axioms(current_timestep)
    yield ASPSubprogramInstantiation(name='apia_axioms', arguments=(current_timestep,))

    # apia_options
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.authorization.value))
    yield from (ASPSubprogramInstantiation(name=subprogram_name, arguments=(current_timestep,))
                for subprogram_name in sorted(configuration.obligation.value))


def main(clingo_control: clingo.Control):
    max_test_number = clingo_control.get_const('test').number
    current_timestep = (max_test_number - 1) // 4
    max_timestep = clingo_control.get_const('max_timestep').number
    aia_step_number = AIALoopStep(((max_test_number - 1) % 4) + 1)

    configuration = APIAConfiguration(authorization=APIAAuthorizationSetting.UTILITARIAN,
                                      obligation=APIAObligationSetting.UTILITARIAN)

    aia_subprograms_to_ground = _generate_aia_subprograms_to_ground(current_timestep, max_timestep, aia_step_number,
                                                                    configuration)

    # test_X
    subprograms_to_ground = tuple(chain(
        aia_subprograms_to_ground,
        (ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=())
         for test_number in range(1, max_test_number + 1)),
    ))
    clingo_control.add('base', (), '\n'.join(f'step({timestep}).'
                                             for timestep in range(max_timestep + 1)))
    print(f'Grounding: {subprograms_to_ground!r}')
    clingo_control.ground(subprograms_to_ground)
    clingo_control.solve()

#end.
