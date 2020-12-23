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

%%%% Convenience predicates %%%%
#program base.

auth_compliance(strong) :-
    not -auth_compliance(strong).

auth_compliance(weak) :-
    not -auth_compliance(weak).

%%%% Expected sequence %%%%

#program test_1.

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 1,
    Actor = "Bob",
    Door = "d12".

#program test_2.

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Bob",
    Door = "d23".

#program test_3.

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Bob",
    Door = "d23".

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Bob",
    Door = "d34".

#program test_4.

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 1,
    Actor = "Bob",
    Door = "d12".

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Bob",
    Door = "d23".

occurs(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Bob",
    Door = "d34".

occurs(greet(Actor, Person), Timestep) :-
    Timestep = 4,
    Actor = "Bob",
    Person = "Alice".

#show holds/2.
#show -holds/2.
#show occurs/2.
#show -occurs/2.
#show permitted/2.
#show -permitted/2.
#show auth_compliance/1.
#show -auth_compliance/1.

#show ("holds", Timestep, Fluent) : holds(Fluent, Timestep).
#show ("holds", Timestep, -Fluent) : -holds(Fluent, Timestep).

#show ("obs", Timestep, Fluent) : observed(Fluent, Timestep).
#show ("obs", Timestep, -Fluent) : -observed(Fluent, Timestep).

#show ("occurs", Timestep, Action) : occurs(Action, Timestep).
#show ("occurs", Timestep, -Action) : -occurs(Action, Timestep).

#show ("hpd", Timestep, Action) : happened(Action, Timestep).
#show ("hpd", Timestep, -Action) : -happened(Action, Timestep).

#show ("attempt", Timestep, Action) : attempt(Action, Timestep).
#show ("attempt", Timestep, -Action) : -attempt(Action, Timestep).

#show ("permitted", Action) : permitted(Action).
#show ("permitted", -Action) : -permitted(Action).

#show ("obl", Happening) : obl(Happening).
#show ("-obl", Happening) : -obl(-Happening).

#show ("prefer", Preferred, Other) : prefer(Preferred, Other).
