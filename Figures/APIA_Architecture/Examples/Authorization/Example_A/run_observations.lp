#program observations_1.

happened(wait, Timestep) :-
    Timestep = 0.

happened(select(greeted_by(Person, Actor)), Timestep) :-
    Timestep = 0,
    Person = "Alice",
    Actor = "Bob".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 1,
    Person = "Alice",
    Actor = "Bob".

#program observations_2.

happened(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 2,
    Person = "Alice",
    Actor = "Bob".

#program observations_3.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Bob",
    Door = "d12".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 3,
    Person = "Bob",
    Room = "r2".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 3,
    Person = "Alice",
    Actor = "Bob".

#program observations_4.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Bob",
    Door = "d23".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 4,
    Person = "Bob",
    Room = "r3".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 4,
    Person = "Alice",
    Actor = "Bob".

#program observations_5.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Bob",
    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Bob",
    Room = "r4".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 5,
    Person = "Alice",
    Actor = "Bob".

#program observations_6.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 5,
    Actor = "Bob",
    Person = "Alice".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Actor = "Bob",
    Person = "Alice".

#program observations_7.

happened(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Alice",
    Actor = "Bob".

#program observations_8.

happened(wait, Timestep) :-
    Timestep = 7.
