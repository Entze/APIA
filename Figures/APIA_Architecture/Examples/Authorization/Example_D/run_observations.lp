% ---------------------------------------------------------------
#program observations_1.

happened(wait, Timestep) :-
    Timestep = 0.

happened(select(policy_compliant(greeted_by(Person, Actor))), Timestep) :-
    Timestep = 0,
    Person = "Bob",
    Actor = "Alice".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 1,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_2.

happened(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 2,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_3.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Alice",
    Door = "d12".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 3,
    Person = "Alice",
    Room = "r2".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 3,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_4.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Alice",
    Door = "d23".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 4,
    Person = "Alice",
    Room = "r3".

observed(door_locked(Door), Timestep) :-
    Timestep = 4,
    Door = "d34".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 4,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_5.

happened(stop(Activity), Timestep) :-
    Timestep = 4,
    Activity = 1.

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Alice",
    Room = "r3".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 5,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_6.

% ---------------------------------------------------------------
#program observations_7.

% ---------------------------------------------------------------
#program observations_8.

% ---------------------------------------------------------------
#program observations_9.

-observed(door_locked(Door), Timestep) :-
    Timestep = 9,
    Door = "d34".

% ---------------------------------------------------------------
#program observations_10.

% ---------------------------------------------------------------
#program observations_11.

% ---------------------------------------------------------------
#program observations_12.

% ---------------------------------------------------------------
#program observations_13.

% ---------------------------------------------------------------
#program observations_14.
