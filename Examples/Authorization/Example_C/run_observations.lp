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

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 4,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_5.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Alice",
    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Alice",
    Room = "r4".

observed(busy_working(Person), Timestep) :-
    Timestep = 5,
    Person = "Bob".

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

% ---------------------------------------------------------------
#program observations_10.

% ---------------------------------------------------------------
#program observations_11.

% ---------------------------------------------------------------
#program observations_12.
