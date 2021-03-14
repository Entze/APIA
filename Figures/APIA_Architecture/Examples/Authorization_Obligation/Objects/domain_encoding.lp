%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% light(Room)
% chair()
% id_badge(Person)
% computer(Computer)
% cellphone(Cellphone)
% cd(CD)

object_generic(light) :-
    light(Room).

object_generic(cellphone) :-
    cellphone(Cellphone).

object_generic(cd) :-
    cd(CD).

object_generic(chair) :-
    cellphone(Cellphone).

% max_object_count(ObjectClass, MaxCount)

object_specific(id_badge(Person)) :-
    id_badge(Person).

object_specific(computer(Computer)) :-
    computer(Computer).

object(Object) :-
    object_generic(Object).

object(Object) :-
    object_specific(Object).

% -------------------------------------------------------

object_attribute(Object, holdable) :-
    object(Object),
    Object = (
        id_badge;
        cellphone;
        cd;
        chair
    ).

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        id_badge
    ),
    Weight = 0.

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        cellphone;
        cd
    ),
    Weight = 1.

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        chair
    ),
    Weight = 2.

object_attribute(Object, sitable) :-
    object(Object),
    Object = (
        chair
    ).

object_attribute(Object, power) :-
    object(Object),
    Object = (
        light;
        computer;
        cellphone
    ).

object_attribute(Object, openable) :-
    object(Object),
    Object = (
        door
    ).

object_attribute(Object, sitable) :-
    object(Object),
    Object = (
        chair
    ).

object_attribute(Object, cd_drive) :-
    object(Object),
    Object = computer(Computer).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(inertial, person_holding_object(Person, Object, ObjectCount)) :-
    person(Person),
    object(Object),
    object_attribute(Object, holdable),
    max_object_count(Object, MaxCount),
    ObjectCount = 0..MaxCount.

fluent(defined, person_holding_object(Person, Object)) :-
    person(Person),
    object(Object),
    object_attribute(Object, holdable).

fluent(defined, person_holding_weight(Person, Weight)) :-
    person(Person),
    Weight = 0..3.

fluent(inertial, person_sitting_on_object(Person, Object)) :-
    person(Person),
    object(Object),
    object_attribute(Object, sitable).

fluent(defined, people_sitting_on_object_count((Location, Object), PeopleCount)) :-
    object(Object),
    object_attribute(Object, sitable),
    location(Location),
    PeopleCount = 0..5.

fluent(inertial, object_turned_on(Location, Object, ObjectCount)) :-
    location(Location),
    object_attribute(Object, power),
    ObjectCount = 0..12.

fluent(inertial, object_location(Object, Location, ObjectCount)) :-
    object(Object),
    location(Location),
    ObjectCount = 0..12.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

%-------------------------------------------------------

% pick_up_object(Actor, Object)
physical_action(pick_up_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, holdable).

agent_action(pick_up_object(Actor, Object)) :-
    physical_action(pick_up_object(Actor, Object)),
    agent(Actor).

exogenous_action(pick_up_object(Actor, Object)) :-
    physical_action(pick_up_object(Actor, Object)),
    not agent(Actor).

%-------------------------------------------------------

% put_down_object(Actor, Object)
physical_action(put_down_object(Actor, Object)) :-
    person(Actor),
    object(Object).

agent_action(put_down_object(Actor, Object)) :-
    physical_action(put_down_object(Actor, Object)),
    agent(Actor).

exogenous_action(put_down_object(Actor, Object)) :-
    physical_action(put_down_object(Actor, Object)),
    not agent(Actor).

%-------------------------------------------------------

% ask_to_put_down_object(Person, Object)
%   - Ignore the specific actor who asked
physical_action(ask_to_put_down_object(Person, Object)) :-
    person(Person),
    object(Object).

agent_action(ask_to_put_down_object(Person, Object)) :-
    physical_action(ask_to_put_down_object(Person, Object)),
    agent(Actor),
    Person = Actor.

exogenous_action(ask_to_put_down_object(Person, Object)) :-
    physical_action(ask_to_put_down_object(Person, Object)),
    person(Person),
    agent(Actor),
    Person != Actor.

%-------------------------------------------------------

% turn_on_object(Actor, Object)
physical_action(turn_on_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_on_object(Actor, Object)) :-
    physical_action(turn_on_object(Actor, Object)),
    agent(Actor),
    Person = Actor.

exogenous_action(turn_on_object(Actor, Object)) :-
    physical_action(turn_on_object(Actor, Object)),
    person(Person),
    agent(Actor),
    Person != Actor.

%-------------------------------------------------------

% turn_off_object(Actor, Object)
physical_action(turn_off_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_off_object(Actor, Object)) :-
    physical_action(turn_off_object(Actor, Object)),
    agent(Actor),
    Person = Actor.

exogenous_action(turn_off_object(Actor, Object)) :-
    physical_action(turn_off_object(Actor, Object)),
    person(Person),
    agent(Actor),
    Person != Actor.

%-------------------------------------------------------

% sit_on_object(Actor, Object)

%-------------------------------------------------------

% stand_up(Actor)
physical_action(stand_up(Actor)) :-
    person(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Picking up increases object count"
%
% pick_up_object(Actor, Object)
%   causes person_holding_object(Actor, Object, ObjectCount + 1)
%   if
%     person_holding_object(Actor, Object, ObjectCount)
holds(person_holding_object(Actor, Object, ObjectCount + 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(pick_up_object(Actor, Object), timestep),
    person_holding_object(Actor, Object, ObjectCount).

% "Only one object count can exist"
%
% -person_holding_object(Actor, Object, OtherObjectCount) if
%   person_holding_object(Actor, Object, ObjectCount),
%   OtherObjectCount != ObjectCount
-holds(person_holding_object(Actor, Object, OtherObjectCount), timestep) :-
    holds(person_holding_object(Actor, Object, ObjectCount), timestep),
    max_object_count(Object, MaxCount),
    OtherObjectCount = 0..MaxCount,
    OtherObjectCount != ObjectCount.

% impossible pick_up_object(Actor, Object) if
%   not object_holdable(Object)
% --
% impossible(pick_up_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% "Cannot pick up more than what is present in the location"
%
% impossible pick_up_object(Actor, Object) if
%   person_location(Actor, Location),
%   object_location(Object, Location, TotalObjectCount),
%   person_holding_object(Actor, Object, HoldingObjectCount),
%   HoldingObjectCount = TotalObjectCount.
impossible(pick_up_object(Actor, Object), timestep) :-
    holds(person_location(Actor, Location), timestep),
    holds(object_location(Object, Location, TotalObjectCount), timestep),
    holds(person_holding_object(Actor, Object, HoldingObjectCount), timestep),
    HoldingObjectCount = TotalObjectCount.

% "Cannot pick up more than we can carry"
%
% impossible pick_up_object(Actor, Object) if
%   object_weight(Object, Weight)
%   person_holding_weight(Person, CarryWeight)
%   NewCarryWeight = Weight + CarryWeight,
%   NewCarryWeight >= 2
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object_weight(Object, Weight),
    holds(person_holding_weight(Person, CarryWeight), timestep),
    NewCarryWeight = Weight + CarryWeight,
    NewCarryWeight >= 2.

% ---------------------------------------------------------------------

% "Define total weight of carried items"
%
% person_holding_weight(Person, Weight) if
%   ...
holds(person_holding_weight(Person, CarryWeight), timestep) :-
    person(Person),
    CarryWeight = #sum{ Weight * ObjectCount, Object :
        holds(person_holding_object(Person, Object, ObjectCount)),
        object_weight(Object, Weight)
    }.

% ---------------------------------------------------------------------

% "Putting down decreases object count"
%
% put_down_object(Actor, Object)
%   causes person_holding_object(Actor, Object, ObjectCount - 1)
%   if
%     person_holding_object(Actor, Object, ObjectCount)
holds(person_holding_object(Actor, Object, ObjectCount - 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(put_down_object(Actor, Object), timestep),
    person_holding_object(Actor, Object, ObjectCount).

% "Cannot put down when we aren't holding anything"
%
% impossible put_down_object(Actor, Object) if
%   person_holding_object(Actor, Object, ObjectCount)
%   ObjectCount = 0
impossible(put_down_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    person_holding_object(Actor, Object, ObjectCount),
    ObjectCount = 0.

% impossible put_down_object(Actor, Object) if
%   not object_holdable(Object)
% ---
% impossible(put_down_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% "Asking to put down decreases object count"
%
% ask_to_put_down_object(Person, Object)
%   causes person_holding_object(Person, Object, ObjectCount - 1)
%   if
%     person_holding_object(Person, Object, ObjectCount)
holds(person_holding_object(Person, Object, ObjectCount - 1), timestep + 1) :-
    person(Person),
    object(Object),
    occurs(ask_to_put_down_object(Person, Object), timestep),
    person_holding_object(Person, Object, ObjectCount).

% "Cannot put down when they aren't holding anything"
%
% impossible ask_to_put_down_object(Person, Object) if
%   person_holding_object(Person, Object, ObjectCount)
%   ObjectCount = 0
impossible(ask_to_put_down_object(Person, Object), timestep) :-
    person(Person),
    object(Object),
    person_holding_object(Person, Object, ObjectCount),
    ObjectCount = 0.

% impossible ask_to_put_down_object(Person, Object) if
%   not object_holdable(Object)
% ---
% impossible(ask_to_put_down_object(Person, Object), timestep) :-
%     person(Person),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% turn_on_object(Actor, Object)
%   causes object_turned_on(Location, Object, ObjectCount + 1)
%   if
%     object_turned_on(Location, Object, ObjectCount)
holds(object_turned_on(Location, Object, ObjectCount + 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(turn_on_object(Actor, Object), timestep),
    holds(object_turned_on(Location, Object, ObjectCount), timestep).

% TODO: Identify by location

% impossible turn_on_object(Actor, Object) if
%   object_turned_on(Location, Object)
impossible(turn_on_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(object_turned_on(Location, Object), timestep).

% impossible turn_on_object(Actor, Object) if
%   not object_requires_power(Object)
% ---
% impossible(turn_on_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_requires_power(Object).

% ---------------------------------------------------------------------

% turn_off_object(Actor, Object)
%   causes object_turned_on(Location, Object, ObjectCount - 1)
%   if
%     object_turned_on(Location, Object, ObjectCount)
holds(object_turned_on(Location, Object, ObjectCount - 1), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(turn_off_object(Actor, Object), timestep),
    holds(object_turned_on(Location, Object, ObjectCount), timestep).

% impossible turn_off_object(Actor, Object) if
%   causes object_turned_on(Location, Object, ObjectCount)
%   ObjectCount = 0
impossible(turn_off_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(object_turned_on(Location, Object, ObjectCount), timestep),
    ObjectCount = 0.

% impossible turn_off_object(Actor, Object) if
%   not object_requires_power(Object)
% ---
% impossible(turn_off_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_requires_power(Object).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Everyone must take their ID badge with them when moving"
%
% obl(pick_up_object(Object)) if
%   Object = id_badge(Actor),
%   -person_holding_object(Actor, Object),
%   occurs(move(Actor, ToLocation))
obl(pick_up_object(Object), timestep) :-
    id_badge(Actor),
    Object = id_badge(Actor),
    occurs(move(Actor, ToLocation), timestep),
    -holds(person_holding_object(Actor, Object), timestep).

% "No one is permitted to carry an electronic device into a classified room"

% "Normally, one must turn off the lights when leaving a room"
%
% lights_1: normally obl(turn_off_object(Actor, Object)) if
%   object(Object),
%   Object = light(Light),
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

