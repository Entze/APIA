#script(python)

from typing import *
from itertools import chain

import clingo


class ASPSubprogramInstantiation(NamedTuple):
    name: str
    arguments: Sequence[Union[str, int]]


def main(clingo_control: clingo.Control):
    max_test_number = clingo_control.get_const('test').number
    current_timestep = (max_test_number - 1) // 4
    stage_number = ((max_test_number - 1) % 4) + 1
    clingo_control.add('base', (), '\n'.join(f'step({timestep}).'
                                             for timestep in range(current_timestep + 1)))
    clingo_control.ground(chain(
        (
            ASPSubprogramInstantiation(name='base', arguments=()),
        ),
        (
            ASPSubprogramInstantiation(name=f'test_{test_number}', arguments=())
            for test_number in range(1, max_test_number + 1)
        ),
        (
            ASPSubprogramInstantiation(name='aia_step_1', arguments=(timestep,))
            for timestep in range(current_timestep)
        ),
        (
            ASPSubprogramInstantiation(name='aia_step_1', arguments=(current_timestep,)),
        ) if stage_number >= 1 else (),
        (
            ASPSubprogramInstantiation(name='aia_step_2', arguments=(timestep,))
            for timestep in range(current_timestep)
        ),
        (
            ASPSubprogramInstantiation(name='aia_step_2', arguments=(current_timestep,)),
        ) if stage_number >= 2 else (),
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

%--- Iteration 1: Step 0 (Initial observation of the world) ---%
#program test_1.

happened(select(greeted_by(Person, Actor)), Timestep) :-
    Timestep = 0,
    Person = "Alice",
    Actor = "Bob".

%--- Iteration 1: Step 1 (Interpret observations) ---%
#program test_1.

% There should be none

%--- Iteration 1: Step 2 (Find intended action) ---%
#program test_2.

% Intended action should be wait
%:-
%    not intended_action(wait, Timestep),
%    Timestep = 0.

%--- Iteration 1: Step 3 (Attempt the intended action) ---%
#program test_3.

attempt(wait, Timestep) :-
    Timestep = 0.

%--- Iteration 1: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_4.

% happened(wait, Timestep) :-
%     Timestep = 1.
%
% happened(select(greeted_by(Person, Actor)), Timestep) :-
%     Timestep = 1,
%     Actor = "Bob",
%     Person = "Alice".



%--- Iteration 2: Step 1 (Interpret observations) ---%
#program test_5.

% active_goal(greeted_by("Alice", "Bob")) should be true

%--- Iteration 2: Step 2 (Find intended action) ---%
#program test_6.

% Intended action should be start(1)

%--- Iteration 2: Step 3 (Attempt the intended action) ---%
#program test_7.

attempt(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

%--- Iteration 2: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_8.

%happened(start(Activity), Timestep) :-
%    Timestep = 2,
%    Activity = 1.



%--- Iteration 3: Step 1 (Interpret observations) ---%
#program test_9.

%--- Iteration 3: Step 2 (Find intended action) ---%
#program test_10.

% Intended action should be move_through("Bob", "d12")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 2,
%    Actor = "Bob",
%    Door = "d12".

%--- Iteration 3: Step 3 (Attempt the intended action) ---%
#program test_11.

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Bob",
    Door = "d12".

%--- Iteration 3: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_12.

%happened(move_through(Actor, Door), Timestep) :-
%    Timestep = 2,
%    Actor = "Bob",
%    Door = "d12".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 3,
    Person = "Bob",
    Room = "r2".



%--- Iteration 4: Step 1 (Interpret observations) ---%
#program test_13.

%--- Iteration 4: Step 2 (Find intended action) ---%
#program test_14.

% Intended action should be move_through("Bob", "d23")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 3,
%    Actor = "Bob",
%    Door = "d23".

%--- Iteration 4: Step 3 (Attempt the intended action) ---%
#program test_15.

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Bob",
    Door = "d23".

%--- Iteration 4: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_16.

%happened(move_through(Actor, Door), Timestep) :-
%    Timestep = 3,
%    Actor = "Bob",
%    Door = "d23".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 4,
    Person = "Bob",
    Room = "r3".



%--- Iteration 5: Step 1 (Interpret observations) ---%
#program test_17.

%--- Iteration 5: Step 2 (Find intended action) ---%
#program test_18.

% Intended action should be move_through("Bob", "d34")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 4,
%    Actor = "Bob",
%    Door = "d23".

%--- Iteration 5: Step 3 (Attempt the intended action) ---%
#program test_19.

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Bob",
    Door = "d34".

%--- Iteration 5: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_20.

%happened(move_through(Actor, Door), Timestep) :-
%    Timestep = 4,
%    Actor = "Bob",
%    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Bob",
    Room = "r4".



%--- Iteration 6: Step 1 (Interpret observations) ---%
#program test_21.

%--- Iteration 6: Step 2 (Find intended action) ---%
#program test_22.

% Intended action should be greet("Bob", "Alice")
%:-
%    not intended_action(greet(Actor, Person), Timestep),
%    Timestep = 5,
%    Actor = "Bob",
%    Person = "Alice".

%--- Iteration 6: Step 3 (Attempt the intended action) ---%
#program test_23.

attempt(greet(Actor, Person), Timestep) :-
    Timestep = 5,
    Actor = "Bob",
    Person = "Alice".

%--- Iteration 6: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_24.

%happened(greet(Actor, Person), Timestep) :-
%    Timestep = 5,
%    Actor = "Bob",
%    Person = "Alice".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Actor = "Bob",
    Person = "Alice".



%--- Iteration 7: Step 1 (Interpret observations) ---%
#program test_25.

%--- Iteration 7: Step 2 (Find intended action) ---%
#program test_26.

% Intended action should be stop(1)
%:-
%    not intended_action(stop(Activity), Timestep),
%    Timestep = 6,
%    Activity = 1.

%--- Iteration 7: Step 3 (Attempt the intended action) ---%
#program test_27.

attempt(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

%--- Iteration 7: Step 4 (Increment timestep & observe the world) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_28.

%happened(stop(Activity), Timestep) :-
%    Timestep = 6,
%    Activity = 1.

%%%% #show statements %%%%

#show holds/2.
#show -holds/2.

#show observed/2.
#show -observed/2.

#show occurs/2.
#show -occurs/2.

#show happened/2.
#show -happened/2.

#show attempt/2.
#show -attempt/2.

#show permitted/2.
#show -permitted/2.

#show obl/2.
#show -obl/2.

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

#show ("permitted", Timestep, Action) : permitted(Action, Timestep).
#show ("permitted", Timestep, -Action) : -permitted(Action, Timestep).

#show ("obl", Timestep, Happening) : obl(Happening, Timestep).
#show ("-obl", Timestep, Happening) : -obl(Happening, Timestep).

#show ("prefer", Preferred, Other) : prefer(Preferred, Other).
