%%%% Domains %%%%

% step(TimeStep)

% room(Room)
% door(Door)
% person(Person)

%%%% Statics %%%%

% door_has_lock(Door)
%door_has_lock(Door) :-
%    door(Door).

%door_to

%%%% Fluents %%%%

% door_locked(Door)
fluent(inertial, door_locked(Door)) :-
    door(Door).

% in_room(Person, Room)
fluent(inertial, in_room(Person, Room)) :-
    person(Person),
    room(Room).

% greeted_by(Person, Actor)
fluent(inertial, greeted_by(Person, Actor)) :-
    person(Person),
    person(Actor),
    Person != Actor.

%%%% Actions %%%%

% move(Actor, Room)
action(move(Actor, Room)) :-
    person(Actor),
    room(Room).

% greet(Actor, Person)
action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

% lock_door(Person, Door)
action(lock_door(Person, Door)) :-
    person(Person),
    door(Door).

% unlock_door(Person, Door)
action(unlock_door(Person, Door)) :-
    person(Person),
    door(Door).

%%%% Action descriptions %%%%

% move(Actor, Room) causes in_room(Actor, Room) if ...
holds(in_room(Actor, Room), TimeStep + 1) :-
    step(TimeStep),
    occurs(move(Actor, Room), TimeStep),
    -ho

%%%% Authorization policy %%%%
