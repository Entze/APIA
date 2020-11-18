#script(python)

from typing import *

import clingo


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[str, int]]


def main(clingo_control: clingo.Control):
    test_number = clingo_control.get_const('test').number
    clingo_control.ground((
        ASPSubprogramInstantiation(name='base', arguments=()),
        ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=()),
    ))
    clingo_control.solve()

#end.

%%%% Expected sequence %%%%

#program test_1.

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 1,
    Actor = "Bob",
    Door = "d12".

#program test_2.

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 2,
    Actor = "Bob",
    Door = "d23".

#program test_3.

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 2,
    Actor = "Bob",
    Door = "d23".

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 3,
    Actor = "Bob",
    Door = "d34".

#program test_4.

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 2,
    Actor = "Bob",
    Door = "d23".

occurs(move_through(Actor, Door), TimeStep) :-
    TimeStep = 3,
    Actor = "Bob",
    Door = "d34".

occurs(greet(Actor, Person), TimeStep) :-
    TimeStep = 4,
    Actor = "Bob",
    Person = "Alice".

#show holds/2.
#show -holds/2.
#show occurs/2.
#show -occurs/2.
#show auth_compliant/0.
#show -auth_compliant/0.
#show auth_compliant/1.
#show -auth_compliant/1.
