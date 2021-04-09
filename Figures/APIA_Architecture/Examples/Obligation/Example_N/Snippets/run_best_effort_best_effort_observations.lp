#program observations_1.

#program observations_2.

happened(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 3.

-observed(security_system_enabled, Timestep) :-
    Timestep = 2.

#program observations_3.

happened(turn_lights_off(Actor, Room), Timestep) :-
    Timestep = 2,
    Actor = "Alice",
    Door = "r1".

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Alice",
    Door = "d12".

-observed(security_system_enabled, Timestep) :-
    Timestep = 3.

#program observations_4.

happened(turn_lights_off(Actor, Room), Timestep) :-
    Timestep = 3,
    Actor = "Alice",
    Door = "r2".

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Alice",
    Door = "d23".

-observed(security_system_enabled, Timestep) :-
    Timestep = 4.

#program observations_5.

happened(turn_lights_off(Actor, Room), Timestep) :-
    Timestep = 4,
    Actor = "Alice",
    Door = "r3".

happened(unlock_door(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Alice",
    Door = "d34".

-observed(security_system_enabled, Timestep) :-
    Timestep = 5.

#program observations_6.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 5,
    Actor = "Alice",
    Door = "d34".

-observed(security_system_enabled, Timestep) :-
    Timestep = 6.

observed(in_room(Person, Room), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Room = "r4".

#program observations_7.

happened(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

-observed(security_system_enabled, Timestep) :-
    Timestep = 7.

#program observations_8.

happened(start(Activity), Timestep) :-
    Timestep = 7,
    Activity = 4.

-observed(security_system_enabled, Timestep) :-
    Timestep = 8.

#program observations_9.

happened(turn_lights_off(Actor, Room), Timestep) :-
    Timestep = 8,
    Actor = "Alice",
    Door = "r4".

happened(ignore_obl(neg(turn_lights_off(Actor, Room))), Timestep) :-
    Timestep = 8,
    Actor = "Alice",
    Door = "r4".

happened(lock_door(Actor, Door), Timestep) :-
    Timestep = 8,
    Actor = "Alice",
    Door = "d34".

-observed(security_system_enabled, Timestep) :-
    Timestep = 9.

#program observations_10.

happened(enable_security_system(Actor), Timestep) :-
    Timestep = 9,
    Actor = "Alice".

observed(security_system_enabled, Timestep) :-
    Timestep = 10.

#program observations_11.

happened(stop(Activity), Timestep) :-
    Timestep = 10,
    Activity = 3.

observed(security_system_enabled, Timestep) :-
    Timestep = 11.

#program observations_12.

happened(wait, Timestep) :-
    Timestep = 11.
