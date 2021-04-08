%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% room(Room)
% door(Door)
% person(Person)
% agent(Agent)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% door_connects(Door, Room)
% door_has_lock(Door)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% door_locked(Door)
physical_fluent(inertial, door_locked(Door)) :-
    door_has_lock(Door).

% in_room(Person, Room)
physical_fluent(inertial, in_room(Person, Room)) :-
    person(Person),
    room(Room).

% greeted_by(Person, Actor)
physical_fluent(inertial, greeted_by(Person, Actor)) :-
    person(Person),
    person(Actor),
    Person != Actor.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% move_through(Actor, Door)
physical_action(move_through(Actor, Door)) :-
    person(Actor),
    door(Door).

agent_action(move_through(Actor, Door)) :-
    physical_action(move_through(Actor, Door)),
    agent(Actor).

exogenous_action(move_through(Actor, Door)) :-
    physical_action(move_through(Actor, Door)),
    not agent(Actor).

% lock_door(Actor, Door)
physical_action(lock_door(Actor, Door)) :-
    person(Actor),
    door_has_lock(Door).

agent_action(lock_door(Actor, Door)) :-
    physical_action(lock_door(Actor, Door)),
    agent(Actor).

exogenous_action(lock_door(Actor, Door)) :-
    physical_action(lock_door(Actor, Door)),
    not agent(Actor).

% unlock_door(Actor, Door)
physical_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door_has_lock(Door).

agent_action(unlock_door(Actor, Door)) :-
    physical_action(unlock_door(Actor, Door)),
    agent(Actor).

exogenous_action(unlock_door(Actor, Door)) :-
    physical_action(unlock_door(Actor, Door)),
    not agent(Actor).

% greet(Actor, Person)
physical_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

agent_action(greet(Actor, Person)) :-
    physical_action(greet(Actor, Person)),
    agent(Actor).

exogenous_action(greet(Actor, Person)) :-
    physical_action(greet(Actor, Person)),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% move_through(Actor, Door)
%   causes in_room(Actor, ToRoom)
%   if
%     in_room(Actor, FromRoom),
%     door_connects(Door, FromRoom),
%     ToRoom != FromRoom
holds(in_room(Actor, ToRoom), timestep + 1) :-
    occurs(move_through(Actor, Door), timestep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Actor, FromRoom), timestep).

% -in_room(Actor, FromRoom) if
%   in_room(Actor, ToRoom),
%   FromRoom != ToRoom
-holds(in_room(Actor, FromRoom), timestep) :-
    room(FromRoom),
    holds(in_room(Actor, ToRoom), timestep),
    FromRoom != ToRoom.

% impossible move_through(Actor, Door) if
%   in_room(Actor, Room),
%   not door_connects(Door, Room)
impossible(move_through(Actor, Door), timestep) :-
    holds(in_room(Actor, Room), timestep),
    door(Door),
    not door_connects(Door, Room).

% lock_door(Actor, Door)
%   causes door_locked(Door)
holds(door_locked(Door), timestep + 1) :-
    occurs(lock_door(Actor, Door), timestep).

% impossible lock_door(Actor, Door) if
%   in_room(Actor, Room),
%   not door_connects(Door, Room)
impossible(lock_door(Actor, Door), timestep) :-
    holds(in_room(Actor, Room), timestep),
    door(Door),
    not door_connects(Door, Room).

% unlock_door(Actor, Door)
%   causes -door_locked(Door)
-holds(door_locked(Door), timestep + 1) :-
    occurs(unlock_door(Actor, Door), timestep).

% impossible unlock_door(Actor, Door) if
%   in_room(Actor, Room),
%   not door_connects(Door, Room)
impossible(unlock_door(Actor, Door), timestep) :-
    holds(in_room(Actor, Room), timestep),
    door(Door),
    not door_connects(Door, Room).

% greet(Actor, Person)
%   causes greeted_by(Person, Actor)
holds(greeted_by(Person, Actor), timestep + 1) :-
    occurs(greet(Actor, Person), timestep).

% impossible greet(Actor, Person) if
%   in_room(Actor, ActorRoom),
%   in_room(Person, PersonRoom),
%   ActorRoom != PersonRoom.
impossible(greet(Actor, Person), timestep) :-
    holds(in_room(Actor, ActorRoom), timestep),
    holds(in_room(Person, PersonRoom), timestep),
    ActorRoom != PersonRoom.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_description(timestep).

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).

% "Anyone is permitted to lock a door"
%
% permitted(lock_door(Actor, Door))
permitted(lock_door(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).

% "Anyone is permitted to unlock a door"
%
% permitted(unlock_door(Actor, Door))
permitted(unlock_door(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).


% "Anyone is allowed to greet a coworker"
%
% permitted(greet(Actor, Person))
permitted(greet(Actor, Person), timestep) :-
    agent(Actor),
    person(Person),
    Actor != Person.
