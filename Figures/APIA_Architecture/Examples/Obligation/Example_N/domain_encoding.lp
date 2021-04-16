%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% room(Room)
% outdoor_room(Room)
% door(Door)
% person(Person)
% agent(Agent)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% private_office(Room)
% supervisor_to(Boss, Person)

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

% room_lights_on(Room)
physical_fluent(inertial, room_lights_on(Room)) :-
    room(Room),
    not outdoor_room(Room).

% all_lights_off
physical_fluent(defined_negative, all_lights_off).

% security_system_enabled
physical_fluent(inertial, security_system_enabled).

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

% ask_to_move_through(Actor, Person, Door)
physical_action(ask_to_move_through(Actor, Person, Door)) :-
    agent(Actor),
    person(Person),
    Actor != Person,
    door(Door).

agent_action(ask_to_move_through(Actor, Person, Door)) :-
    physical_action(ask_to_move_through(Actor, Person, Door)),
    agent(Actor).

exogenous_action(ask_to_move_through(Actor, Person, Door)) :-
    physical_action(ask_to_move_through(Actor, Person, Door)),
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

% turn_lights_on(Actor, Room)
physical_action(turn_lights_on(Actor, Room)) :-
    person(Actor),
    room(Room).

agent_action(turn_lights_on(Actor, Room)) :-
    physical_action(turn_lights_on(Actor, Room)),
    agent(Actor).

exogenous_action(turn_lights_on(Actor, Room)) :-
    physical_action(turn_lights_on(Actor, Room)),
    not agent(Actor).

% turn_lights_off(Actor, Room)
physical_action(turn_lights_off(Actor, Room)) :-
    person(Actor),
    room(Room).

agent_action(turn_lights_off(Actor, Room)) :-
    physical_action(turn_lights_off(Actor, Room)),
    agent(Actor).

exogenous_action(turn_lights_off(Actor, Room)) :-
    physical_action(turn_lights_off(Actor, Room)),
    not agent(Actor).

% enable_security_system(Actor)
physical_action(enable_security_system(Actor)) :-
    person(Actor).

agent_action(enable_security_system(Actor)) :-
    physical_action(enable_security_system(Actor)),
    agent(Actor).

exogenous_action(enable_security_system(Actor)) :-
    physical_action(enable_security_system(Actor)),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% move_through(Actor, Door)
%   causes in_room(Actor, ToRoom)
%   if
%     in_room(Actor, FromRoom),
%     door_connects(Door, ToRoom),
%     ToRoom != FromRoom
holds(in_room(Actor, ToRoom), timestep + 1) :-
    occurs(move_through(Actor, Door), timestep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Actor, FromRoom), timestep).

% ask_to_move_through(Actor, Person, Door)
%   causes in_room(Person, ToRoom)
%   if
%     in_room(Person, FromRoom),
%     door_connects(Door, ToRoom),
%     ToRoom != FromRoom
holds(in_room(Person, ToRoom), timestep + 1) :-
    occurs(ask_to_move_through(Actor, Person, Door), timestep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Person, FromRoom), timestep).

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

% impossible ask_to_move_through(Actor, Person, Door) if
%   in_room(Person, Room),
%   not door_connects(Door, Room)
impossible(ask_to_move_through(Actor, Person, Door), timestep) :-
    person(Actor),
    holds(in_room(Person, Room), timestep),
    door(Door),
    not door_connects(Door, Room).

% impossible move_through(Actor, Door) if
%   door_locked(Door)
impossible(move_through(Actor, Door), timestep) :-
    person(Actor),
    holds(door_locked(Door), timestep).

% impossible ask_to_move_through(Actor, Person, Door) if
%   door_locked(Door)
impossible(ask_to_move_through(Actor, Person, Door), timestep) :-
    person(Actor),
    person(Person),
    holds(door_locked(Door), timestep).

% impossible ask_to_move_through(Actor, Person, Door) if
%   in_room(Actor, ActorRoom),
%   in_room(Person, PersonRoom),
%   ActorRoom != PersonRoom
impossible(ask_to_move_through(Actor, Person, Door), timestep) :-
    holds(in_room(Actor, ActorRoom), timestep),
    holds(in_room(Person, PersonRoom), timestep),
    ActorRoom != PersonRoom,
    door(Door).

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

% turn_lights_on(Actor, Room)
%   causes room_lights_on(Room)
holds(room_lights_on(Room), timestep + 1) :-
    occurs(turn_lights_on(Actor, Room), timestep).

% impossible turn_lights_on(Actor, Room) if
%   -in_room(Actor, Room)
impossible(turn_lights_on(Actor, Room), timestep) :-
    -holds(in_room(Actor, Room), timestep).

% turn_lights_off(Actor, Room)
%   causes -room_lights_on(Room)
-holds(room_lights_on(Room), timestep + 1) :-
    occurs(turn_lights_off(Actor, Room), timestep).

% impossible turn_lights_off(Actor, Room) if
%   -in_room(Actor, Room)
impossible(turn_lights_off(Actor, Room), timestep) :-
    -holds(in_room(Actor, Room), timestep).

% -all_lights_off if
%   room_lights_on(Room)
-holds(all_lights_off, timestep) :-
    holds(room_lights_on(Room), timestep).

% enable_security_system(Actor)
%   causes security_system_enabled
holds(security_system_enabled, timestep + 1) :-
    occurs(enable_security_system(Actor), timestep).

% impossible enable_security_system if
%   security_system_enabled
impossible(enable_security_system(Actor), timestep) :-
    person(Actor),
    holds(security_system_enabled, timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_description(timestep).

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).

% "Anyone is allowed to ask another to move from any room to any room"
%
% permitted(ask_to_move_through(Actor, Door))
permitted(ask_to_move_through(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).

% "Normally, anyone is allowed to enable the security system"
%
% normally permitted(enable_security_system(Actor))
permitted(enable_security_system(Actor), timestep) :-
    agent(Actor),
    not -permitted(enable_security_system(Actor), timestep),
    not obl(neg(enable_security_system(Actor)), timestep).

% "One is obligated not to turn off the lights if someone else is in the room"
%
% obl(-turn_lights_off(Actor, Room)) if
%   person(Person)
%   not agent(Person)
%   in_room(Person, Room)
obl(neg(turn_lights_off(Actor, Room)), timestep) :-
    agent(Actor),
    person(Person),
    not agent(Person),
    holds(in_room(Person, Room), timestep).

% "One is obligated not to enable the security system if not all lights are off"
%
% obl(-enable_security_system(Actor)) if
%   -all_lights_off
obl(neg(enable_security_system(Actor)), timestep) :-
    agent(Actor),
    -holds(all_lights_off, timestep).

% "One is obligated not to enable the security system if a door is unlocked"
%
% obl(-enable_security_system(Actor)) if
%   -door_locked(Door)
obl(neg(enable_security_system(Actor)), timestep) :-
    agent(Actor),
    -holds(door_locked(Door), timestep).

% "Anyone is permitted to lock a door"
%
% permitted(lock_door(Actor, Door))
permitted(lock_door(Actor, Door), timestep) :-
    agent(Actor),
    door_has_lock(Door).

% "Anyone is permitted to unlock a door"
%
% permitted(unlock_door(Actor, Door))
permitted(unlock_door(Actor, Door), timestep) :-
    agent(Actor),
    door_has_lock(Door).

% "Normally, anyone is permittted to turn on the lights"
%
% normally permitted(turn_lights_on(Actor, Room))
permitted(turn_lights_on(Actor, Room), timestep) :-
    agent(Actor),
    room(Room),
    not -permitted(turn_lights_on(Actor, Room), timestep),
    not obl(neg(turn_lights_on(Actor, Room)), timestep).

% "Normally, anyone is permittted to turn off the lights"
%
% normally permitted(turn_lights_off(Actor, Room))
permitted(turn_lights_off(Actor, Room), timestep) :-
    agent(Actor),
    room(Room),
    not -permitted(turn_lights_off(Actor, Room), timestep),
    not obl(neg(turn_lights_off(Actor, Room)), timestep).
