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

object_attribute(Object, houses) :-
    object(Object).

object_attribute(Object, insertable) :-
    object(Object),
    Object = (
        id_badge;
        cd
    ).

object_insertable_in(Object, HousingObject) :-
    object(Object),
    object(HousingObject),
    Object = (
        id_badge;
    ),
    HousingObject = (
        door
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

fluent(defined, person_remaining_holding_space(Person, Weight)) :-
    person(Person),
    Weight = 0..3.

fluent(inertial, object_in(InnerObject, HousingObject)) :-
    object_insertable_in(InnerObject, HousingObject).

fluent(defined, inserted_object_count(HousingObject, Object, ObjectCount)) :-
    object_insertable_in(Object, HousingObject),
    ObjectCount = 0..2.

fluent(inertial, object_turned_on(Object)) :-
    object_attribute(Object, power).

fluent(inertial, object_location(Object, Location)) :-
    object(Object),
    location(Location).

fluent(inertial, cd_drive_full(Object)) :-
    object_attribute(Object, cd_drive).

fluent(inertial, chair_count(Location, Chairs)) :-
    location(Location),
    Chairs = 0..12.  % TODO: Parameterize this value

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

%-------------------------------------------------------

% pick_up_object(Actor, Object)
physical_action(pick_up_object(Actor, Object)) :-
    person(Actor),
    object(Object).

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
    person(Person),
    agent(Actor),
    Person != Actor.

exogenous_action(ask_to_put_down_object(Person, Object)) :-
    physical_action(ask_to_put_down_object(Person, Object)),
    person(Person),
    agent(Actor),
    Person != Actor.

%-------------------------------------------------------

% insert_object(Actor, Object, HousingObject)
physical_action(insert_object(Actor, Object, HousingObject)) :-
    person(Actor),
    object_attribute(Object, insertable),
    object_attribute(HousingObject, houses),
    object_insertable_in(Object, HousingObject).

agent_action(insert_object(Actor, Object, HousingObject)) :-
    physical_action(insert_object(Actor, Object, HousingObject)).
    agent(Actor),

exogenous_action(insert_object(Actor, Object, HousingObject)) :-
    physical_action(insert_object(Actor, Object, HousingObject)).
    not agent(Actor).

%-------------------------------------------------------

% remove_object(Actor, Object, HousingObject)
physical_action(remove_object(Actor, Object, HousingObject)) :-
    person(Actor),
    object_attribute(Object, insertable),
    object_attribute(HousingObject, houses),
    object_insertable_in(Object, HousingObject).

agent_action(remove_object(Actor, Object, HousingObject)) :-
    agent(Actor),
    object_attribute(Object, insertable),
    object_attribute(HousingObject, houses),
    object_insertable_in(Object, HousingObject).

exogenous_action(remove_object(Actor, Object, HousingObject)) :-
    person(Actor),
    not agent(Actor),
    object_attribute(Object, insertable),
    object_attribute(HousingObject, houses),
    object_insertable_in(Object, HousingObject).

%-------------------------------------------------------

% turn_on_object(Actor, Object)
physical_action(turn_on_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_on_object(Actor, Object)) :-
    agent(Actor),
    object(Object),
    object_attribute(Object, power).

exogenous_action(turn_on_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object),
    object_attribute(Object, power).

%-------------------------------------------------------

% turn_off_object(Actor, Object)
physical_action(turn_off_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_off_object(Actor, Object)) :-
    agent(Actor),
    object(Object),
    object_attribute(Object, power).

exogenous_action(turn_off_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object),
    object_attribute(Object, power).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% pick_up_object(Actor, Object)
%   causes person_holding_object(Actor, Object)
holds(person_holding_object(Actor, Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(pick_up_object(Actor, Object), timestep).

% impossible pick_up_object(Actor, Object) if
%   not object_holdable(Object)
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    not object_holdable(Object).

% impossible pick_up_object(Actor, Object) if
%   location

% impossible pick_up_object(Actor, Object) if
%   person_holding_object(Actor, Object)
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(person_holding_object(Actor, Object), timestep).

% impossible pick_up_object(Actor, Object) if
%   object_weight(Object, Weight)
%   person_remaining_holding_space(Person, CarryWeight)
%   NewCarryWeight = Weight + CarryWeight,
%   NewCarryWeight >= 2
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object_weight(Object, Weight),
    holds(person_remaining_holding_space(Person, CarryWeight), timestep),
    NewCarryWeight = Weight + CarryWeight,
    NewCarryWeight >= 2.

% ---------------------------------------------------------------------

% person_remaining_holding_space(Person, Weight) if
%   ...
holds(person_remaining_holding_space(Person, CarryWeight), timestep) :-
    person(Person),
    CarryWeight = #sum{ Weight, Object :
        holds(person_holding_object(Person, Object)),
        object_weight(Object, Weight)
    }.

% ---------------------------------------------------------------------

% put_down_object(Actor, Object)
%   causes -person_holding_object(Actor, Object)
-holds(person_holding_object(Actor, Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(put_down_object(Actor, Object), timestep).

% impossible put_down_object(Actor, Object) if
%   -person_holding_object(Actor, Object)
impossible(put_down_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    -holds(person_holding_object(Actor, Object), timestep).

% impossible put_down_object(Actor, Object) if
%   not object_holdable(Object)
% ---
% impossible(put_down_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% ask_to_put_down_object(Person, Object)
%   causes -person_holding_object(Person, Object)
-holds(person_holding_object(Person, Object), timestep + 1) :-
    person(Person),
    object(Object),
    occurs(ask_to_put_down_object(Person, Object), timestep).

% impossible ask_to_put_down_object(Person, Object) if
%   -person_holding_object(Person, Object)
impossible(ask_to_put_down_object(Person, Object), timestep) :-
    person(Person),
    object(Object),
    -holds(person_holding_object(Person, Object), timestep).

% impossible ask_to_put_down_object(Person, Object) if
%   not object_holdable(Object)
% ---
% impossible(ask_to_put_down_object(Person, Object), timestep) :-
%     person(Person),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% insert_object(Actor, Object, HousingObject)
%   causes object_in(Object, HousingObject)
holds(object_in(Object, HousingObject), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(insert_object(Actor, Object, HousingObject), timestep).

% insert_object(Actor, Object, HousingObject)
%   causes -person_holding_object(Actor, Object)
-holds(person_holding_object(Actor, Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(insert_object(Actor, Object, HousingObject), timestep).

% impossible insert_object(Actor, Object, HousingObject)
%   location

% impossible insert_object(Actor, Object, HousingObject) if
%   not object_insertable(Object, HousingObject)
% ---
% impossible(insert_object(Actor, Object, HousingObject), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% impossible insert_object(Actor, Object, HousingObject) if
%   object_in(Object, _)
impossible(insert_object(Actor, Object, HousingObject), timestep) :-
    action(Action),
    Action = insert_object
    person(Actor),
    object(Object),
    holds(object_in(Object, _), timestep).

% impossible insert_object(Actor, Object, HousingObject) if
%   inserted_object_count(Person, ObjectCount)
%   ObjectCount = 1
impossible(insert_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    holds(person_remaining_holding_space(Person, Weight), timestep),
    ObjectCount = 2.

% ---------------------------------------------------------------------

% remove_object(Actor, Object, HousingObject)
%   causes -object_in(Object, HousingObject)
-holds(object_in(Object, HousingObject), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(remove_object(Actor, Object, HousingObject), timestep).

% remove_object(Actor, Object, HousingObject)
%   causes person_holding_object(Actor, Object)
holds(person_holding_object(Actor, Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(remove_object(Actor, Object, HousingObject), timestep).

% impossible remove_object(Actor, Object, HousingObject) if
%   -person_holding_object(Actor, Object)
impossible(remove_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    object(Object),
    -holds(person_holding_object(Actor, Object), timestep).

% impossible remove_object(Actor, Object, HousingObject) if
%   not object_holdable(Object)
% ---
% impossible(remove_object(Actor, Object, HousingObject), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% turn_on_object(Actor, Object)
%   causes object_turned_on(Object)
holds(object_turned_on(Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(turn_on_object(Actor, Object), timestep).

% impossible turn_on_object(Actor, Object) if
%   object_turned_on(Object)
impossible(turn_on_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(object_turned_on(Object), timestep).

% impossible turn_on_object(Actor, Object) if
%   not object_requires_power(Object)
% ---
% impossible(turn_on_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_requires_power(Object).

% ---------------------------------------------------------------------

% turn_off_object(Actor, Object)
%   causes -object_turned_on(Object)
-holds(object_turned_on(Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(turn_off_object(Actor, Object), timestep).

% impossible turn_off_object(Actor, Object) if
%   -object_turned_on(Object)
impossible(turn_off_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    -holds(object_turned_on(Object), timestep).

% impossible turn_off_object(Actor, Object) if
%   not object_requires_power(Object)
% ---
% impossible(turn_off_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_requires_power(Object).

% ---------------------------------------------------------------------

% move(Actor, ToLocation)
%   causes object_location(Object, ToLocation)
%   if
%     person_holding_object(Actor, Object)
holds(object_location(Object, ToLocation), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_holding_object(Actor, Object), timestep).

% move(Actor, ToLocation)
%   causes object_location(Object, ToLocation)
%   if
%     object_in(Object, HousingObject)
%     person_holding_object(Actor, HousingObject)
holds(object_location(Object, ToLocation), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(object_in(Object, HousingObject), timestep),
    holds(person_holding_object(Actor, HousingObject), timestep).

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

