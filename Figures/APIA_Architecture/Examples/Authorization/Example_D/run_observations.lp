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

happened(stop(Activity), Timestep) :-
    Timestep = 5,
    Activity = 1.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_7.

happened(start(Activity), Timestep) :-
    Timestep = 6,
    Activity = 3.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_8.

happened(knock_on_door(Actor, Door), Timestep) :-
    Timestep = 7,
    Actor = "Alice",
    Door = "d34".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 8,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_9.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 8,
    Actor = "Alice",
    Person = "Bob".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 9,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_10.

happened(stop(Activity), Timestep) :-
    Timestep = 9,
    Activity = 3.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 10,
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
#program observations_11.

happened(wait, Timestep) :-
    Timestep = 10.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 11,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_12.

happened(wait, Timestep) :-
    Timestep = 11.
