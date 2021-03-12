%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% id_badge(Person)
% computer(Computer)
% computer_has(Computer, cd_drive)
% cellphone(Cellphone)
% cd(CD)

object(id_badge(Person)) :-
    id_badge(Person).

object(computer(Computer)) :-
    computer(Computer).

object(cellphone(Cellphone)) :-
    cellphone(Cellphone).

object(cd(CD)) :-
    cd(CD).

object_holdable(Object) :-
    object(Object).

housing_object(HousingObject) :-
    object(Object).

object_insertable_in(Object, HousingObject) :-
    object(Object),
    object(HousingObject).

object_requires_power(Object) :-
    object(Object).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(inertial, object_held_by(Object, Person)) :-
    object_holdable(Object),
    person(Person).

fluent(defined, person_object_count(Person, ObjectCount)) :-
    person(Person),
    ObjectCount = 0..3.

fluent(inertial, object_in(InnerObject, HousingObject)) :-
    object_insertable_in(InnerObject, HousingObject).

fluent(defined, inserted_object_count(HousingObject, ObjectCount)) :-
    housing_object(HousingObject),
    ObjectCount = 0..2.

fluent(inertial, object_turned_on(Object)) :-
    object_requires_power(Object).

fluent(inertial, object_location(Object, Location)) :-
    object(Object),
    location(Location).

fluent(inertial, cd_drive_full(Computer)) :-
    computer_has(Computer, cd_drive).

fluent(inertial, chair_count(Location, Chairs)) :-
    location(Location),
    Chairs = 0..12.  % TODO: Parameterize this value

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

% pick_up_object(Actor, Object)
physical_action(pick_up_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

agent_action(pick_up_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

exogenous_action(pick_up_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

% put_down_object(Actor, Object)
physical_action(put_down_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

agent_action(put_down_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

exogenous_action(put_down_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

% insert_object(Actor, Object, HousingObject)
physical_action(insert_object(Actor, Object, HousingObject)) :-
    agent(Actor),
    object(Object).

agent_action(insert_object(Actor, Object, HousingObject)) :-
    agent(Actor),
    object(Object).

exogenous_action(insert_object(Actor, Object, HousingObject)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

% remove_object(Actor, Object, HousingObject)
physical_action(remove_object(Actor, Object, HousingObject)) :-
    agent(Actor),
    object(Object).

agent_action(remove_object(Actor, Object, HousingObject)) :-
    agent(Actor),
    object(Object).

exogenous_action(remove_object(Actor, Object, HousingObject)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

% turn_on_object(Actor, Object)
physical_action(turn_on_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

agent_action(turn_on_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

exogenous_action(turn_on_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

% turn_off_object(Actor, Object)
physical_action(turn_off_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

agent_action(turn_off_object(Actor, Object)) :-
    agent(Actor),
    object(Object).

exogenous_action(turn_off_object(Actor, Object)) :-
    person(Actor),
    not agent(Actor),
    object(Object).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% pick_up_object(Actor, Object)
%   causes object_held_by(Object, Person)
holds(object_held_by(Object, Person), timestep + 1) :-
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
%   person_object_count(Person, ObjectCount)
%   ObjectCount = 2
impossible(pick_up_object(Actor, Object), timestep) :-
    person(Actor),
    holds(person_object_count(Person, ObjectCount), timestep),
    ObjectCount = 2.

% ---------------------------------------------------------------------

% person_object_count(Person, ObjectCount) if
%   ...
holds(person_object_count(Person, ObjectCount), timestep) :-
    person(Person),
    ObjectCount = #count{ Object : holds(object_held_by(Object, Person)) }.

% ---------------------------------------------------------------------

% put_down_object(Actor, Object)
%   causes -object_held_by(Object, Person)
-holds(object_held_by(Object, Person), timestep + 1) :-
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
impossible(put_down_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    not object_holdable(Object).

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
impossible(insert_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    object(Object),
    not object_holdable(Object).

% impossible insert_object(Actor, Object, HousingObject) if
%   object_in(Object, _)
impossible(insert_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    object(Object),
    holds(object_in(Object, _), timestep).

% impossible insert_object(Actor, Object, HousingObject) if
%   inserted_object_count(Person, ObjectCount)
%   ObjectCount = 1
impossible(insert_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    holds(person_object_count(Person, ObjectCount), timestep),
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
impossible(remove_object(Actor, Object, HousingObject), timestep) :-
    person(Actor),
    object(Object),
    not object_holdable(Object).

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
impossible(turn_on_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    not object_requires_power(Object).

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
impossible(turn_off_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    not object_requires_power(Object).

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
% obl(pick_up_object(id_badge(Actor))) if
%   -object_held_by(id_badge(Actor), Actor),
%   occurs(move(Actor, ToLocation))
obl(pick_up_object(id_badge(Actor)), timestep) :-
    occurs(move(Actor, ToLocation), timestep),
    -holds(object_held_by(id_badge(Actor), Actor), timestep).
