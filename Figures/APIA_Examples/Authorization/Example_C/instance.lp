%%%% Domains %%%%
#program base.

room(Room) :-
    Room = ("r1"; "r2"; "r3"; "r4").

door(Door) :-
    Door = ("d12"; "d23"; "d34").

person(Person) :-
    Person = ("Bob"; "Alice").

%%%% Statics %%%%
#program base.

door_connects(Door, Room) :-
    Door = "d12",
    Room = ("r1"; "r2").

door_connects(Door, Room) :-
    Door = "d23",
    Room = ("r2"; "r3").

door_connects(Door, Room) :-
    Door = "d34",
    Room = ("r3"; "r4").

door_has_lock(Door) :-
    Door = "d34".

%%%% Starting fluent values %%%%
#program base.

-holds(door_locked(Door), TimeStep) :-
    TimeStep = 0,
    Door = "d34".

holds(in_room(Person, Room), TimeStep) :-
    TimeStep = 0,
    Person = "Bob",
    Room = "r1".

holds(in_room(Person, Room), TimeStep) :-
    TimeStep = 0,
    Person = "Alice",
    Room = "r4".

holds(greeted_by(Person, Actor), TimeStep) :-
    TimeStep = 0,
    person(Person),
    person(Actor),
    Person != Actor.

% Also check for unsatisfiable answer sets
