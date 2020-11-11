#script(python)

from typing import *

import clingo


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[int, str, clingo.Symbol]]


def main(clingo_control: clingo.Control):
    clingo_control.ground((
        ASPSubprogramInstantiation(name='base', arguments=()),
        ASPSubprogramInstantiation(name='action_description', arguments=(3,)),
    ))
    clingo_control.solve()


#end.
