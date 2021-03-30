%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% location(Location)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cubical(Location)
% private_office(Location)

% room(Room)
% main_room(Room)
% location_room(Location, Room)
% conference_room(Room)
% room_classified(Room)

% path(Location1, Location2)
% door(Location1, Location2)
% door_has_lock(Location1, Location2)
% door_autolock_pause(FromLocation, ToLocation, Timesteps)

% action_duration(Action, Duration)

path(Location2, Location1) :-
    path(Location1, Location2).

path(Location1, Location2) :-
    door(Location1, Location2).

action_duration(Action, Duration) :-
    mental_action(Action),
    Duration = 0.

action_duration(Action, Duration) :-
    policy_action(Action),
    Duration = 0.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = move(Actor, ToLocation),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = unlock_door(Actor, FromLocation, ToLocation),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = lock_door(Actor, FromLocation, ToLocation),
    Duration = 15.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% person_location(Person, Location)
physical_fluent(inertial, person_location(Person, Location)) :-
    person(Person),
    location(Location).

% door_locked(FromLocation, ToLocation)
physical_fluent(inertial, door_locked(FromLocation, ToLocation)) :-
    door_has_lock(FromLocation, ToLocation).

% door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
physical_fluent(inertial, door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)) :-
    door_has_lock(FromLocation, ToLocation),
    TimestepsLeft = 0..3.

% time(Hour, Minute)
physical_fluent(inertial, time(Hour, Minute)) :-
    Hour = 0..23,
    Minute = (0; 15; 30; 45).

% time_business_hours
physical_fluent(defined, time_business_hours).

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

% unlock_door(Actor, FromLocation, ToLocation)
physical_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    person(Actor),
    door_has_lock(FromLocation, ToLocation).

agent_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(unlock_door(Actor, FromLocation, ToLocation)),
    agent(Actor).

exogenous_action(unlock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(unlock_door(Actor, FromLocation, ToLocation)),
    not agent(Actor).

% lock_door(Actor, FromLocation, ToLocation)
physical_action(lock_door(Actor, FromLocation, ToLocation)) :-
    person(Actor),
    door_has_lock(FromLocation, ToLocation).

agent_action(lock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(lock_door(Actor, FromLocation, ToLocation)),
    agent(Actor).

exogenous_action(lock_door(Actor, FromLocation, ToLocation)) :-
    physical_action(lock_door(Actor, FromLocation, ToLocation)),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% move(Actor, ToLocation)
%   causes person_location(Actor, ToLocation)
holds(person_location(Actor, ToLocation), timestep + 1) :-
    occurs(move(Actor, ToLocation), timestep).

% impossible move(Actor, ToLocation) if
%   person_location(Actor, FromLocation),
%   not path(FromLocation, ToLocation)

% impossible move(Actor, ToLocation) if
%   person_location(Actor, FromLocation),
%   door_locked(FromLocation, ToLocation)
impossible(move(Actor, ToLocation), timestep) :-
    holds(person_location(Actor, FromLocation), timestep),
    holds(door_locked(FromLocation, ToLocation), timestep).

% ---------------------------------------------------------------------

% move(Actor, ToLocation)
%   causes object_location(Object, ToLocation, ObjectCount + 1)
%   if
%     person_holding_object(Actor, Object)
%     object_location(Object, ToLocation, ObjectCount)
holds(object_location(Object, ToLocation, ObjectCount + 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_holding_object(Actor, Object), timestep),
    holds(object_location(Object, ToLocation, ObjectCount), timestep).

% move(Actor, ToLocation)
%   causes object_location(Object, FromLocation, ObjectCount - 1)
%   if
%     person_holding_object(Actor, Object),
%     person_location(Actor, FromLocation),
%     object_location(Object, FromLocation, ObjectCount)
holds(object_location(Object, FromLocation, ObjectCount - 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_holding_object(Actor, Object), timestep),
    holds(person_location(Actor, FromLocation), timestep),
    holds(object_location(Object, FromLocation, ObjectCount), timestep).

% -------------------------------------------------------------------

% unlock_door(Actor, FromLocation, ToLocation)
%   causes -door_locked(FromLocation, ToLocation)
%   if
%     person_holding_object(Actor, Object)
%     Object = id_badge.
-holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(unlock_door(Actor, FromLocation, ToLocation), timestep),
    holds(person_holding_object(Actor, Object), timestep),
    Object = id_badge.

% impossible unlock_door(Actor, FromLocation, ToLocation) if
%   person_location(Actor, Location),
%   FromLocation != Location
impossible(unlock_door(Actor, FromLocation, ToLocation), timestep) :-
    door_has_lock(FromLocation, ToLocation),
    holds(person_location(Actor, Location), timestep),
    FromLocation != Location.

% unlock_door(Actor, FromLocation, ToLocation)
%   causes door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
%   if
%     door_autolock_pause(FromLocation, ToLocation, Timesteps)
%     TimestepsLeft = Timesteps
holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep + 1) :-
    occurs(unlock_door(Actor, FromLocation, ToLocation), timestep),
    door_autolock_pause(FromLocation, ToLocation, Timesteps),
    TimestepsLeft = Timesteps.

% -------------------------------------------------------------------

% lock_door(Actor, FromLocation, ToLocation)
%   causes door_locked(FromLocation, ToLocation)
holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(lock_door(Actor, FromLocation, ToLocation), timestep).

% impossible lock_door(Actor, FromLocation, ToLocation) if
%   person_location(Actor, Location),
%   FromLocation != Location
%   ToLocation != Location
impossible(lock_door(Actor, FromLocation, ToLocation), timestep) :-
    door_has_lock(FromLocation, ToLocation),
    holds(person_location(Actor, Location), timestep),
    FromLocation != Location,
    ToLocation != Location.

% lock_door(Actor, FromLocation, ToLocation)
%   causes door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
%   if
%     TimestepsLeft = 0
holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep + 1) :-
    occurs(lock_door(Actor, FromLocation, ToLocation), timestep),
    TimestepsLeft = 0.

% -------------------------------------------------------------------

% Action
%   causes door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft - 1)
%   if
%     physical_action(Action)
%     door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft)
%     TimestepsLeft > 0,
%     not -door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft - 1)
holds(door_autolock_countdown(FromLocation, ToLocation, NewTimestepsLeft), timestep) :-
    occurs(Action, timestep),
    physical_action(Action),
    holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep),
    TimestepsLeft > 0,
    NewTimestepsLeft = TimestepsLeft - 1,
    not -holds(door_autolock_countdown(FromLocation, ToLocation, NewTimestepsLeft), timestep).

% Action
%   causes door_locked(FromLocation, ToLocation)
%   if
%     physical_action(Action)
%     door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft),
%     TimestempsLeft = 1
holds(door_locked(FromLocation, ToLocation), timestep) :-
    occurs(Action, timestep),
    physical_action(Action),
    holds(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), timestep),
    TimestempsLeft = 1.

% -------------------------------------------------------------------

% Action
%   causes time(NewHour, NewMinute)
%   if
%     agent_action(Action)
%     time(Hour, Minute),
%     action_duration(Action, Duration)
%     Duration > 0
%     NewTime = (Hour * 60 + Minute) + Duration
%     NewMinute = NewTime \ 60
%     NewHour = (NewTime / 60) \ 24
holds(time(NewHour, NewMinute), timestep + 1) :-
    MaxDuration = #max{ Duration, Action :
        occurs(Action, timestep),
        agent_action(Action),
        action_duration(Action, Duration)
    },
    MaxDuration > 0,
    holds(time(Hour, Minute), timestep),
    NewTime = (Hour * 60 + Minute) + MaxDuration,
    NewMinute = NewTime \ 60,
    NewHour = (NewTime / 60) \ 24.

% -time(OtherHour, Minute) if
%   time(Hour, Minute)
-holds(time(OtherHour, OtherMinute), timestep) :-
    holds(time(Hour, Minute), timestep),
    physical_fluent(inertial, time(OtherHour, OtherMinute)),
    (Hour, Minute) != (OtherHour, OtherMinute).

% -------------------------------------------------------------------

% time_business_hours if
%   time(Hour, Minute),
%   Hour >= 8,
%   Hour < 5
holds(time_business_hours, timestep) :-
    holds(time(Hour, Minute), timestep),
    Hour >= 8,
    Hour < 5.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_description(timestep).

% "Normally, anyone is allowed to move from room to room"
%
% normally permitted(move(Actor, ToLocation))
permitted(move(Actor, ToLocation), timestep) :-
    agent(Actor),
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
%   location_room(ToLocation, Room)
%   room_classified(Room)
-permitted(move(Actor, ToLocation), timestep) :-
    agent(Actor),
    location(ToLocation),
    location_room(ToLocation, Room),
    room_classified(Room).

% "Everyone with electronic devices is not allowed to enter a classified room"
%
% -permitted(move(Actor, ToLocation)) if
%   location_room(ToLocation, Room)
%   room_classified(Room)
-permitted(move(Actor, ToLocation), timestep) :-
    agent(Actor),
    location(ToLocation),
    location_room(ToLocation, Room),
    room_classified(Room).
