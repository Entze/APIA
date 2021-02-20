% See p. 74 of dissertation for AIA control loop

#script(python)

from enum import IntEnum
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


def generate_aia_subprograms_to_ground(current_timestep: int, step_number: AIALoopStep):
    # base
    yield ASPSubprogramInstantiation(name='base', arguments=())

    # axioms(timestep)
    yield from (ASPSubprogramInstantiation(name='axioms', arguments=(timestep,))
                for timestep in range(current_timestep + 1))

    # action_description(timestep)
    yield from (ASPSubprogramInstantiation(name='action_description', arguments=(timestep,))
                for timestep in range(current_timestep + 1))

    # aia_history_rules(timestep)
    yield from (ASPSubprogramInstantiation(name='aia_history_rules', arguments=(timestep,))
                for timestep in range(current_timestep))
    if step_number >= 1:
        yield ASPSubprogramInstantiation(name='aia_history_rules', arguments=(current_timestep,))

    # aia_intended_action_rules(timestep)
    yield from (ASPSubprogramInstantiation(name='aia_intended_action_rules', arguments=(timestep,))
                for timestep in range(current_timestep))
    if step_number >= 2:
        yield ASPSubprogramInstantiation(name='aia_intended_action_rules', arguments=(current_timestep,))


def main(clingo_control: clingo.Control):
    max_test_number = clingo_control.get_const('test').number
    current_timestep = (max_test_number - 1) // 4
    aia_step_number = AIALoopStep(((max_test_number - 1) % 4) + 1)

    aia_subprograms_to_ground = generate_aia_subprograms_to_ground(current_timestep, aia_step_number)

    # test_X
    subprograms_to_ground = tuple(chain(
        aia_subprograms_to_ground,
        (ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=())
         for test_number in range(1, max_test_number + 1)),
    ))
    clingo_control.add('base', (), '\n'.join(f'step({timestep}).'
                                             for timestep in range(current_timestep + 1)))
    print(f'Grounding: {subprograms_to_ground!r}')
    clingo_control.ground(subprograms_to_ground)
    clingo_control.solve()

#end.

%%%% Convenience predicates %%%%
#program base.

auth_compliance(strong) :-
    not -auth_compliance(strong).

auth_compliance(weak) :-
    not -auth_compliance(weak).
