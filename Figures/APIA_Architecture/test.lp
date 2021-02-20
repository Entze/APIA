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


def main(clingo_control: clingo.Control):
    max_test_number = clingo_control.get_const('test').number
    current_timestep = (max_test_number - 1) // 4
    aia_step_number = AIALoopStep(((max_test_number - 1) % 4) + 1)
    clingo_control.add('base', (), '\n'.join(f'step({timestep}).'
                                             for timestep in range(current_timestep + 1)))
    subprograms_to_ground = tuple(chain(
        (
            ASPSubprogramInstantiation(name='base', arguments=()),
        ),
        (
            ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=())
            for test_number in range(1, max_test_number + 1)
        ),
        (
            ASPSubprogramInstantiation(name='aia_axioms', arguments=(timestep,))
            for timestep in range(current_timestep)
        ),
        (
            ASPSubprogramInstantiation(name='aia_axioms', arguments=(current_timestep,)),
        ) if aia_step_number >= 1 else (),
        (
            ASPSubprogramInstantiation(name='aia_step_1', arguments=(timestep,))
            for timestep in range(current_timestep)
        ),
        (
            ASPSubprogramInstantiation(name='aia_step_1', arguments=(current_timestep,)),
        ) if aia_step_number >= 1 else (),
        (
            ASPSubprogramInstantiation(name='aia_step_2', arguments=(timestep,))
            for timestep in range(current_timestep)
        ),
        (
            ASPSubprogramInstantiation(name='aia_step_2', arguments=(current_timestep,)),
        ) if aia_step_number >= 2 else (),
    ))
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
