%%%% Domains %%%%

room(Room) :-
    Room = ("r1"; "r2"; "r3"; "r4").

door(Door) :-
    Door = ("d12"; "d23"; "d34").

person(Person) :-
    Person = ("Bob"; "Alice").

%%%% Statics %%%%

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

%%%% Initial observations (before AIA control loop) %%%%
% See p. 50 of dissertation

-observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Bob",
    Room = "r1".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Alice",
    Room = "r4".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 0,
    person(Person),
    person(Actor),
    Person != Actor.

% Theory of Intentions

-holds(active_goal(Goal), Timestep) :-
    Timestep = 0,
    fluent(inertial, active_goal(Goal)).

holds(status(Activity, ActivityIndex), Timestep) :-
    Timestep = 0,
    fluent(inertial, status(Activity, ActivityIndex)),
    ActivityIndex = -1.

-holds(next_name(Activity), Timestep) :-
    Timestep = 0,
    fluent(inertial, next_name(Activity)).
