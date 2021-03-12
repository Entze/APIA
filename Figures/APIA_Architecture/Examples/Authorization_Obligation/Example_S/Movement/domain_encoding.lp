%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location(Location)
% cubical(Location)
% private_office(Location)

% room(Room)
% location_room(Location, Room)
% conference_room(Room)
% classification(room(Room), Classification)

% path(Location1, Location2)
% door(Location1, Location2)
% door_has_lock(Location1, Location2)

path(Location2, Location1) :-
    path(Location1, Location2).

path(Location1, Location2) :-
    door(Location1, Location2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% person_location(Person, Location)
fluent(inertial, person_location(Person, Location)) :-
    person(Person),
    location(Location).

% door_locked(FromLocation, ToLocation)
fluent(inertial, door_locked(FromLocation, ToLocation)) :-
    door_has_lock(FromLocation, ToLocation).

% door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
fluent(inertial, door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)) :-
    door_has_lock(FromLocation, ToLocation),
    TimestepsLeft = 0..3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

% move(Actor, ToLocation)
physical_action(move(Actor, ToLocation)) :-
    person(Actor),
    location(ToLocation).

agent_action(move(Actor, ToLocation)) :-
    physical_action(move(Actor, ToLocation)),
    agent(Actor).

exogenous_action(move(Actor, ToLocation)) :-
    physical_action(move(Actor, ToLocation)),
    not agent(Actor).

% stand(Actor)
physical_action(stand(Actor)) :-
    person(Actor).

agent_action(stand(Actor)) :-
    physical_action(stand(Actor)),
    person(Actor).

exogenous_action(stand(Actor)) :-
    physical_action(stand(Actor)),
    not agent(Actor).

% sit_in_chair(Actor, ChairType)
physical_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor).

agent_action(sit_in_chair(Actor, ChairType)) :-
    physical_action(sit_in_chair(Actor, ChairType)),
    agent(Actor).

exogenous_action(sit_in_chair(Actor, ChairType)) :-
    physical_action(sit_in_chair(Actor, ChairType)),
    not agent(Actor).

% unlock_door(Actor, FromLocation, ToLocation)
physical_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    door_has_lock(FromLocation, ToLocation),
    agent(Actor).

agent_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(unlock_door(Actor, FromLocation, ToLocation)),
    agent(Actor).

exogenous_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(unlock_door(Actor, FromLocation, ToLocation)),
    not agent(Actor).

% lock_door(FromLocation, ToLocation)
%   - Ignore the actor that locked the door
physical_action(lock_door(FromLocation, ToLocation)) :-
    door_has_lock(FromLocation, ToLocation).

agent_action(lock_door(FromLocation, ToLocation)) :-
    physical_action(lock_door(FromLocation, ToLocation)).

exogenous_action(lock_door(FromLocation, ToLocation)) :-
    physical_action(lock_door(FromLocation, ToLocation)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% move(Actor, ToLocation)
%   causes person_location(Actor, ToLocation)
holds(person_location(Actor, ToLocation), timestep + 1) :-
    occurs(move(Actor, ToLocation), timestep).

% impossible move(Actor, ToLocation) if
%   person_location(Actor, FromLocation),
%   not path(FromLocation, ToLocation)

% -------------------------------------------------------------------

% unlock_door(Actor, FromLocation, ToLocation)
%   causes -door_locked(FromLocation, ToLocation)
%   if
%     object_in(id_badge(Actor), HousingObject)
%     HousingObject = door(FromLocation, ToLocation)
-holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(unlock_door(Actor, FromLocation, ToLocation), timestep),
    holds(object_in(id_badge(Actor), door(FromLocation, ToLocation)), timestep).

% -------------------------------------------------------------------

% lock_door(FromLocation, ToLocation)
%   causes door_locked(FromLocation, ToLocation)
holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(lock_door(FromLocation, ToLocation), timestep).

% -------------------------------------------------------------------

% Action
%   causes door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft - 1)
%   if
%     door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
%     TimestepsLeft > 0,
%     not -door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft - 1)
holds(door_autolock_countdown(FromLocation, ToLocation, NewTimestepsLeft), timestep) :-
    occurs(_, timestep),
    holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep),
    TimestepsLeft > 0,
    NewTimestepsLeft = TimestepsLeft - 1,
    not -holds(door_autolock_countdown(FromLocation, ToLocation, NewTimestepsLeft), timestep).

% Action
%   causes door_locked(FromLocation, ToLocation)
%   if
%     door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft),
%     TimestempsLeft = 1
holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(_, timestep),
    holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep),
    TimestempsLeft = 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Normally, anyone is allowed to move from room to room"
%
% normally permitted(move(Actor, ToLocation))
permitted(move(Actor, ToLocation), timestep) :-
    person(Actor),
    location(ToLocation),
    not -permitted(move(Actor, ToLocation), timestep).

% "Normally, no one is allowed to sit down in someone's cubicle"

% "Normally, one is allowed to sit down in someone's cubicle if the owner of the cubicle is there"

% "You are allowed to sit down in your own cubicle"

% "Normally, no one is allowed to sit down in someone's private office"

% "Normally, one is allowed to sit down in someone's private office if the owner of the office is there"

% "You are allowed to sit down in your own private office"

% "You are allowed to open the door to your own office"

% "No one without security clearance can enter a classified room."
%
% -permitted(move(Actor, ToLocation)) if
%   location(location(Location), room(Room)),
%   classified(room(Room))
-permitted(move(Actor, ToLocation), timestep) :-
    location(location(Location), room(Room)),
    classified(room(Room)).

% "Everyone with electronic devices is not allowed to enter a classified room"
%
% -permitted(move(Actor, ToLocation)) if
%   location(location(Location), room(Room)),
%   classified(room(Room))
-permitted(move(Actor, ToLocation), timestep) :-
    location(location(Location), room(Room)),
    classified(room(Room)),
