%%%% Domains %%%%

% step(Timestep)

% room(Room)
% door(Door)
% person(Person)

%%%% Statics %%%%

% door_connects(Door, Room)
% door_has_lock(Door)

%%%% Fluents %%%%

% door_locked(Door)
fluent(inertial, door_locked(Door)) :-
    door(Door).

% in_room(Person, Room)
fluent(inertial, in_room(Person, Room)) :-
    person(Person),
    room(Room).

% busy_working(Person)
fluent(inertial, busy_working(Person)) :-
    person(Person).

% knocked_on_door(Door)
fluent(inertial, knocked_on_door(Door)) :-
    door(Door).

% greeted_by(Person, Actor)
fluent(inertial, greeted_by(Person, Actor)) :-
    person(Person),
    person(Actor),
    Person != Actor.

%%%% Actions %%%%

% move_through(Actor, Door)
physical_agent_action(move_through(Actor, Room)) :-
    person(Actor),
    room(Room).

physical_exogenous_action(move_through(Actor, Room)) :-
    person(Actor),
    room(Room).

% lock_door(Actor, Door)
physical_agent_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% unlock_door(Actor, Door)
physical_agent_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% knock_on_door(Actor, Door)
physical_agent_action(knock_on_door(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(knock_on_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% begin_working(Actor)
physical_agent_action(begin_working(Actor)) :-
    person(Actor).

physical_exogenous_action(begin_working(Actor)) :-
    person(Actor).

% greet(Actor, Person)
physical_agent_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

physical_exogenous_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

%%%% Action descriptions %%%%

% move_through(Actor, Door) causes in_room(Actor, ToRoom)
%   if in_room(Actor, FromRoom), door_connects(Door, FromRoom),
%      ToRoom != FromRoom
holds(in_room(Actor, ToRoom), Timestep + 1) :-
    step(Timestep),
    occurs(move_through(Actor, Door), Timestep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Actor, FromRoom), Timestep).

% -in_room(Actor, FromRoom) if in_room(Actor, ToRoom)
-holds(in_room(Actor, FromRoom), Timestep) :-
    room(FromRoom),
    holds(in_room(Actor, ToRoom), Timestep),
    FromRoom != ToRoom.

% impossible move_through(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(move_through(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% lock_door(Actor, Door) causes door_locked(Door)
holds(door_locked(Door), Timestep + 1) :-
    step(Timestep),
    occurs(lock_door(Actor, Door), Timestep).

% impossible lock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(lock_door(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% unlock_door(Actor, Door) causes -door_locked(Door)
-holds(door_locked(Door), Timestep + 1) :-
    step(Timestep),
    occurs(unlock_door(Actor, Door), Timestep).

% impossible unlock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(unlock_door(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% knock_on_door(Actor, Door) causes knocked_on_door(Door)
holds(knocked_on_door(Door), Timestep + 1) :-
    step(Timestep),
    occurs(knock_on_door(Actor, Door), Timestep).

% impossible knock_on_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(knock_on_door(Actor, Door), Timestep) :-
    step(Timestep),
    door(Door),
    holds(in_room(Actor, Room), Timestep),
    not door_connects(Door, Room).

% begin_working(Actor) causes busy_working(Actor)
holds(busy_working(Actor), Timestep + 1) :-
    occurs(begin_working(Actor), Timestep).

% greet(Actor, Person) causes greeted_by(Person, Actor)
holds(greeted_by(Person, Actor), Timestep + 1) :-
    step(Timestep),
    occurs(greet(Actor, Person), Timestep).

% impossible greet(Actor, Person)
%   if in_room(Actor, ActorRoom), in_room(Person, PersonRoom),
%      ActorRoom != PersonRoom.
-occurs(greet(Actor, Person), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, ActorRoom), Timestep),
    holds(in_room(Person, PersonRoom), Timestep),
    ActorRoom != PersonRoom.

%%%% Authorization policy %%%%

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), Timestep) :-
    step(Timestep),
    person(Actor),
    door(Door).

% "Anyone is allowed to greet a coworker if the coworker is not busy working"
%
% permitted(greet(Actor, Person))
%   if not busy_working(Person)
permitted(greet(Actor, Person), Timestep) :-
    step(Timestep),
    person(Actor),
    person(Person),
    not holds(busy_working(Person), Timestep),
    Actor != Person.

% "Anyone is allowed to greet a coworker if the coworker is busy working but he/she has knocked on the door (to the room they are in)"
%
% permitted(greet(Actor, Person))
%   if busy_working(Person), in_room(Person, Room),
%      door_connects(Door, Room), knocked_on_door(Door)
permitted(greet(Actor, Person), Timestep) :-
    step(Timestep),
    person(Actor),
    person(Person),
    Actor != Person,
    holds(busy_working(Person), Timestep),
    holds(in_room(Person, Room), Timestep),
    door_connects(Door, Room),
    holds(knocked_on_door(Door), Timestep).
