%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% light(Room)
% chair()
% id_badge(Person)
% computer(Computer)
% cellphone(Cellphone)
% cd(CD)

object(light(Room)) :-
    light(Room).

object(id_badge(Person)) :-
    id_badge(Person).

object(computer(Computer)) :-
    computer(Computer).

object(cellphone(Cellphone)) :-
    cellphone(Cellphone).

object(cd(CD)) :-
    cd(CD).

% -------------------------------------------------------

object_attribute(Object, holdable) :-
    object(Object),
    Object = (
        id_badge(Person);
        cellphone(Cellphone);
        cd(CD);
        chair(Chair)
    ).

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        id_badge(Person)
    ),
    Weight = 0.

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        cellphone(Cellphone);
        cd(CD)
    ),
    Weight = 1.

object_weight(Object, Weight) :-
    object_attribute(Object, holdable),
    Object = (
        chair(Chair)
    ),
    Weight = 2.

object_attribute(Object, houses) :-
    object(Object).

object_attribute(Object, insertable) :-
    object(Object),
    Object = (
        id_badge(Person);
        cd(CD)
    ).

object_insertable_in(Object, HousingObject) :-
    object(Object),
    object(HousingObject),
    Object = (
        id_badge(Person);
    ),
    HousingObject = (
        door()
    ).

object_attribute(Object, power) :-
    object(Object),
    Object = (
        light(Room);
        computer(Computer);
        cellphone(Cellphone)
    ).

object_attribute(Object, openable) :-
    object(Object),
    Object = (
        door()
    ).

object_attribute(Object, sitable) :-
    object(Object),
    Object = (
        chair()
    ).

object_attribute(Object, cd_drive) :-
    object(Object),
    Object = computer(Computer).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(inertial, object_held_by(Object, Person)) :-
    object_attribute(Object, holdable),
    person(Person).

fluent(defined, person_object_carry_weight(Person, Weight)) :-
    person(Person),
    Weight = 0..3.

fluent(inertial, object_in(InnerObject, HousingObject)) :-
    object_insertable_in(InnerObject, HousingObject).

fluent(defined, inserted_object_count(HousingObject, ObjectCount)) :-
    object_attribute(HousingObject, housing),
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
%   causes object_held_by(Object, Actor)
holds(object_held_by(Object, Actor), timestep + 1) :-
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
%   object_held_by(Object, Actor)
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(object_held_by(Object, Actor), timestep).

% impossible pick_up_object(Actor, Object) if
%   object_weight(Object, Weight)
%   person_object_carry_weight(Person, CarryWeight)
%   NewCarryWeight = Weight + CarryWeight,
%   NewCarryWeight >= 2
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    object_weight(Object, Weight),
    holds(person_object_carry_weight(Person, CarryWeight), timestep),
    NewCarryWeight = Weight + CarryWeight,
    NewCarryWeight >= 2.

% ---------------------------------------------------------------------

% person_object_carry_weight(Person, Weight) if
%   ...
holds(person_object_carry_weight(Person, CarryWeight), timestep) :-
    person(Person),
    CarryWeight = #sum{ Weight, Object :
        holds(object_held_by(Object, Person)),
        object_weight(Object, Weight)
    }.

% ---------------------------------------------------------------------

% put_down_object(Actor, Object)
%   causes -object_held_by(Object, Actor)
-holds(object_held_by(Object, Actor), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(put_down_object(Actor, Object), timestep).

% impossible put_down_object(Actor, Object) if
%   -object_held_by(Object, Actor)
impossible(put_down_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    -holds(object_held_by(Object, Actor), timestep).

% impossible put_down_object(Actor, Object) if
%   not object_holdable(Object)
% ---
% impossible(put_down_object(Actor, Object), timestep) :-
%     person(Actor),
%     object(Object),
%     not object_holdable(Object).

% ---------------------------------------------------------------------

% ask_to_put_down_object(Person, Object)
%   causes -object_held_by(Object, Person)
-holds(object_held_by(Object, Person), timestep + 1) :-
    person(Person),
    object(Object),
    occurs(ask_to_put_down_object(Person, Object), timestep).

% impossible ask_to_put_down_object(Person, Object) if
%   -object_held_by(Object, Person)
impossible(ask_to_put_down_object(Person, Object), timestep) :-
    person(Person),
    object(Object),
    -holds(object_held_by(Object, Person), timestep).

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
%   causes -object_held_by(Actor, Object)
-holds(object_held_by(Actor, Object), timestep + 1) :-
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
    holds(person_object_carry_weight(Person, Weight), timestep),
    ObjectCount = 2.

% ---------------------------------------------------------------------

% remove_object(Actor, Object, HousingObject)
%   causes -object_in(Object, HousingObject)
-holds(object_in(Object, HousingObject), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(remove_object(Actor, Object, HousingObject), timestep).

% remove_object(Actor, Object, HousingObject)
%   causes object_held_by(Actor, Object)
holds(object_held_by(Actor, Object), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(remove_object(Actor, Object, HousingObject), timestep).

% impossible remove_object(Actor, Object, HousingObject) if
%   -object_held_by(Object, Actor)
impossible(remove_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    object(Object),
    -holds(object_held_by(Object, Actor), timestep).

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
%     object_held_by(Object, Actor)
holds(object_location(Object, ToLocation), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(object_held_by(Object, Actor), timestep).

% move(Actor, ToLocation)
%   causes object_location(Object, ToLocation)
%   if
%     object_in(Object, HousingObject)
%     object_held_by(HousingObject, Actor)
holds(object_location(Object, ToLocation), timestep + 1) :-
    person(Actor),
    object(Object),
    occurs(move(Actor, ToLocation), timestep),
    holds(object_in(Object, HousingObject), timestep),
    holds(object_held_by(HousingObject, Actor), timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Everyone must take their ID badge with them when moving"
%
% obl(pick_up_object(Object)) if
%   Object = id_badge(Actor),
%   -object_held_by(Object, Actor),
%   occurs(move(Actor, ToLocation))
obl(pick_up_object(Object), timestep) :-
    id_badge(Actor),
    Object = id_badge(Actor),
    occurs(move(Actor, ToLocation), timestep),
    -holds(object_held_by(Object, Actor), timestep).

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

