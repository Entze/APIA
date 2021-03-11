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
    person(Actor),
    agent(Actor),
    location(ToLocation).

exogenous_action(move(Actor, ToLocation)) :-
    person(Actor),
    not agent(Actor),
    location(ToLocation).

% stand(Actor)
physical_action(stand(Actor)) :-
    person(Actor).

agent_action(stand(Actor)) :-
    person(Actor),
    agent(Actor).

exogenous_action(stand(Actor)) :-
    person(Actor),
    not agent(Actor).

% sit_in_chair(Actor, ChairType)
physical_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor).

agent_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor),
    agent(Actor).

exogenous_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor),
    not agent(Actor).

% unlock_door(Actor, Door)
physical_action(unlock_door(Actor, Door)) :-
    agent(Actor).

agent_action(unlock_door(Actor, Door)) :-
    agent(Actor).

exogenous_action(unlock_door(Actor, Door)) :-
    person(Actor),
    not agent(Actor).

% lock_door(Actor, Door)
physical_action(lock_door(Actor, Door)) :-
    agent(Actor).

agent_action(lock_door(Actor, Door)) :-
    agent(Actor).

exogenous_action(lock_door(Actor, Door)) :-
    person(Actor),
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Normally, anyone is allowed to move from room to room"
%
% normally permitted(move(Actor, ToLocation))
permitted(move(Actor, ToLocation), timestep) :-
    person(Actor),
    location(ToLocation),
    not -permitted(move(Actor, ToLocation), timestep).

% "Normally, one must turn off the lights when leaving a room"
%
% lights_1: normally obl(turn_off_lights(Actor, OldRoom)) if
%   occurs(move(Actor, ToLocation)),
%   location_room(Location, NewRoom),
%   OldRoom != NewRoom.

% "Normally, one must not turn off the lights when leaving the main room"
%
% lights_2: normally obl(turn_off_lights(Actor, OldRoom)) if
%   occurs(move(Actor, ToLocation)),
%   location_room(Location, NewRoom),
%   OldRoom != NewRoom,
%   main_room(OldRoom)

% prefer(lights_2, lights_1)
abnormal(lights_1, timestep) :-
    . % TODO: Complete

% "Normally, one must turn off the lights when leaving a room after hours"

% "Never turn off the lights when someone else is in the room"
%
% obl(neg(turn_off_lights(Actor, Room))) if
%   ...

% "Normally, no one is allowed to sit down in someone's cubicle"

% "Normally, one is allowed to sit down in someone's cubicle if the owner of the cubicle is there"

% "You are allowed to sit down in your own cubicle"

% "Normally, no one is allowed to sit down in someone's private office"

% "Normally, one is allowed to sit down in someone's private office if the owner of the office is there"

% "You are allowed to sit down in your own private office"

% "You are allowed to open the door to your own office"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% Starting ID for generated activities
#const ir = 1.

% goal(Goal) :-
%     Goal = %* ... *%,
%
% activity(Activity) :-
%     Activity = 1.
%
% activity_goal(Activity, ActivityGoal) :-
%     Activity = 1,
%     ActivityGoal = %* ... *%.
%
% activity_length(Activity, ActivityLength) :-
%     Activity = 1,
%     ActivityLength = #max{ ComponentIndex : activity_component(Activity, ComponentIndex, _) }.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 1,
%     Component = %* ... *%.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 2,
%     Component = %* ... *%.
%
% ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation
#program base.

-observed(bar(B), Timestep) :-
    Timestep = 0,
    b(B).

observed(baz(C), Timestep) :-
    Timestep = 0,
    c(C).
