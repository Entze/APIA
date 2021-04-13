%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% room(Room)
% door(Door)
% person(Person)
% agent(Agent)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% private_office(Room)

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
    room(Room).

% all_lights_off
physical_fluent(defined_negative, all_lights_off).

% security_system_enabled
physical_fluent(inertial, security_system_enabled).

% is_business_hours
physical_fluent(inertial, is_business_hours).

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
physical_action(enable_security_system(Actor, Room)) :-
    person(Actor),
    room(Room).

agent_action(enable_security_system(Actor, Room)) :-
    physical_action(enable_security_system(Actor, Room)),
    agent(Actor).

exogenous_action(enable_security_system(Actor, Room)) :-
    physical_action(enable_security_system(Actor, Room)),
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

% impossible move_through(Actor, Door) if
%   door_locked(Door)
impossible(move_through(Actor, Door), timestep) :-
    person(Actor),
    holds(door_locked(Door), timestep).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_description(timestep).

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), timestep) :-
    agent(Actor),
    door(Door).

% "One is normally obligated not to turn off the lights if someone else is in the room"
%
% lights_someone_else(Actor, Room): normally obl(-turn_lights_off(Actor, Room)) if
%   person(Person)
%   not agent(Person)
%   in_room(Person, Room)
obl(neg(turn_lights_off(Actor, Room)), timestep) :-
    agent(Actor),
    person(Person),
    not agent(Person),
    holds(in_room(Person, Room), timestep),
    not abnormal(lights_someone_else(Actor, Room), timestep),
    not -obl(neg(turn_lights_off(Actor, Room)), timestep),
    not permitted(turn_lights_off(Actor, Room), timestep).

% "One is obligated not to enable the security system if not all lights are off"
%
% lights_security_system(Actor): normally obl(-enable_security_system(Actor)) if
%   -all_lights_off
obl(neg(enable_security_system(Actor)), timestep) :-
    agent(Actor),
    -holds(all_lights_off, timestep),
    not abnormal(lights_security_system(Actor), timestep),
    not -obl(neg(enable_security_system(Actor)), timestep),
    not permitted(enable_security_system(Actor), timestep).

% prefer(lights_someone_else(Actor, Room), lights_security_system(Actor))
abnormal(lights_security_system(Actor), timestep) :-
    % Condition of lights_someone_else(Actor, Room)
    agent(Actor),
    person(Person),
    not agent(Person),
    holds(in_room(Person, Room), timestep).

% % prefer(lights_security_system(Actor), lights_someone_else(Actor, Room))
% abnormal(lights_someone_else(Actor, Room), timestep) :-
%     % Condition of lights_security_system(Actor)
%     agent(Actor),
%     -holds(all_lights_off, timestep).

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
