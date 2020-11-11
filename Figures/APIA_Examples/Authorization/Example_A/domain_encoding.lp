%%%% Domains %%%%

% step(TimeStep)

% room(Room)
% door(Door)
% person(Person)

%%%% Statics %%%%

% door_connects(Door, Room)
% door_has_lock(Door)

%%%% Fluents %%%%
#program base.

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
#program base.

% move_through(Actor, Door)
action(move_through(Actor, Room)) :-
    person(Actor),
    room(Room).

% lock_door(Actor, Door)
action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% unlock_door(Actor, Door)
action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% greet(Actor, Person)
action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

%%%% Action descriptions %%%%
#program action_description.

% move_through(Actor, Door) causes in_room(Actor, ToRoom)
%   if in_room(Actor, FromRoom), door_connects(Door, FromRoom),
%      ToRoom != FromRoom
% ???
holds(in_room(Actor, ToRoom), TimeStep + 1) :-
    step(TimeStep),
    occurs(move_through(Actor, Door), TimeStep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Actor, FromRoom), TimeStep).

% -in_room(Actor, FromRoom) if in_room(Actor, ToRoom)
-holds(in_room(Actor, FromRoom), TimeStep) :-
    room(FromRoom),
    holds(in_room(Actor, ToRoom), TimeStep),
    FromRoom != ToRoom.

% impossible move_through(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(move_through(Actor, Door), TimeStep) :-
    step(TimeStep),
    holds(in_room(Actor, Room), TimeStep),
    door(Door),
    not door_connects(Door, Room).

% lock_door(Actor, Door) causes door_locked(Door)
holds(door_locked(Door), TimeStep + 1) :-
    step(TimeStep),
    occurs(lock_door(Actor, Door), TimeStep).

% impossible lock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(lock_door(Actor, Door), TimeStep) :-
    step(TimeStep),
    holds(in_room(Actor, Room), TimeStep),
    door(Door),
    not door_connects(Door, Room).

% unlock_door(Actor, Door) causes -door_locked(Door)
-holds(door_locked(Door), TimeStep + 1) :-
    step(TimeStep),
    occurs(unlock_door(Actor, Door), TimeStep).

% impossible unlock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(unlock_door(Actor, Door), TimeStep) :-
    step(TimeStep),
    holds(in_room(Actor, Room), TimeStep),
    door(Door),
    not door_connects(Door, Room).

% greet(Actor, Person) causes greeted_by(Person, Actor)
holds(greeted_by(Person, Actor), TimeStep + 1) :-
    step(TimeStep),
    occurs(greet(Actor, Person), TimeStep).

% impossible greet(Actor, Person)
%   if in_room(Actor, ActorRoom), in_room(Person, PersonRoom),
%      ActorRoom != PersonRoom.
-occurs(greet(Actor, Person), TimeStep) :-
    step(TimeStep),
    holds(in_room(Actor, ActorRoom), TimeStep),
    holds(in_room(Person, PersonRoom), TimeStep),
    ActorRoom != PersonRoom.

%%%% Authorization policy %%%%
#program base.

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), TimeStep) :-
    step(TimeStep),
    person(Actor),
    door(Door).

% "Anyone is allowed to greet a coworker"
%
% permitted(greet(Actor, Person))
permitted(greet(Actor, Person), TimeStep) :-
    step(TimeStep),
    person(Actor),
    person(Person),
    Actor != Person.
