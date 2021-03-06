%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% person_max_holding_weight(Person, MaxWeight)
% max_object_count(MaxObjectCount)

object(Object) :-
    Object = (
        id_badge;
        light;
        cellphone;
        cd;
        computer;
        chair
    ).

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

object_attribute(Object, power) :-
    object(Object),
    Object = (
        light;
        computer;
        cellphone
    ).

object_attribute(Object, electronic) :-
    object(Object),
    Object = (
        computer;
        cellphone
    ).

% object_attribute(Object, sittable) :-
%     object(Object),
%     Object = (
%         chair
%     ).

object_attribute(Object, cd_drive) :-
    object(Object),
    Object = computer.

% ----------------------------------------------------------------

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = pick_up_object(Actor, Object),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = put_down_object(Actor, Object),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = ask_to_put_down_object(Actor, Person, Object),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = turn_on_object(Actor, Object),
    Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = turn_off_object(Actor, Object),
    Duration = 15.

% action_duration(Action, Duration) :-
%     agent_action(Action),
%     Action = sit_on_object(Actor, Object),
%     Duration = 15.

action_duration(Action, Duration) :-
    agent_action(Action),
    Action = stand_up(Actor),
    Duration = 15.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

physical_fluent(inertial, person_holding_object(Person, Object, ObjectCount)) :-
    person(Person),
    object(Object),
    object_attribute(Object, holdable),
    max_object_count(MaxObjectCount),
    ObjectCount = 0..MaxObjectCount.

physical_fluent(defined, person_holding_object(Person, Object)) :-
    person(Person),
    object(Object),
    object_attribute(Object, holdable).

physical_fluent(defined, person_holding_weight(Person, Weight)) :-
    person(Person),
    person_max_holding_weight(Person, MaxWeight),
    Weight = 0..MaxWeight.

% physical_fluent(inertial, person_sitting_on_object(Person, Object)) :-
%     person(Person),
%     object(Object),
%     object_attribute(Object, sittable).

% physical_fluent(defined, people_sitting_on_object_count((Location, Object), PeopleCount)) :-
%     object(Object),
%     object_attribute(Object, sittable),
%     location(Location),
%     MaxPeopleCount = #count{ Person : person(Person) },
%     PeopleCount = 0..MaxPeopleCount.

physical_fluent(inertial, object_turned_on(Location, Object, ObjectCount)) :-
    location(Location),
    object_attribute(Object, power),
    max_object_count(MaxObjectCount),
    ObjectCount = 0..MaxObjectCount.

physical_fluent(inertial, object_location(Object, Location, ObjectCount)) :-
    object(Object),
    location(Location),
    max_object_count(MaxObjectCount),
    ObjectCount = 0..MaxObjectCount.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions or exogenous actions (we assume actions cannot be both)

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

% ask_to_put_down_object(Actor, Person, Object)
physical_action(ask_to_put_down_object(Actor, Person, Object)) :-
    person(Actor),
    person(Person),
    object(Object).

agent_action(ask_to_put_down_object(Actor, Person, Object)) :-
    physical_action(ask_to_put_down_object(Actor, Person, Object)),
    agent(Actor).

exogenous_action(ask_to_put_down_object(Actor, Person, Object)) :-
    physical_action(ask_to_put_down_object(Actor, Person, Object)),
    not agent(Actor).

%-------------------------------------------------------

% turn_on_object(Actor, Object)
physical_action(turn_on_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_on_object(Actor, Object)) :-
    physical_action(turn_on_object(Actor, Object)),
    agent(Actor).

exogenous_action(turn_on_object(Actor, Object)) :-
    physical_action(turn_on_object(Actor, Object)),
    not agent(Actor).

%-------------------------------------------------------

% turn_off_object(Actor, Object)
physical_action(turn_off_object(Actor, Object)) :-
    person(Actor),
    object(Object),
    object_attribute(Object, power).

agent_action(turn_off_object(Actor, Object)) :-
    physical_action(turn_off_object(Actor, Object)),
    agent(Actor).

exogenous_action(turn_off_object(Actor, Object)) :-
    physical_action(turn_off_object(Actor, Object)),
    not agent(Actor).

%-------------------------------------------------------

% % sit_on_object(Actor, Object)
% physical_action(sit_on_object(Actor, Object)) :-
%     person(Actor),
%     object(Object),
%     object_attribute(Object, sittable).
%
% agent_action(sit_on_object(Actor, Object)) :-
%     physical_action(sit_on_object(Actor, Object)),
%     agent(Actor).
%
% exogenous_action(sit_on_object(Actor, Object)) :-
%     physical_action(sit_on_object(Actor, Object)),
%     not agent(Actor).

%-------------------------------------------------------

% stand_up(Actor)
physical_action(stand_up(Actor)) :-
    person(Actor).

agent_action(stand_up(Actor)) :-
    physical_action(stand_up(Actor)),
    agent(Actor).

exogenous_action(stand_up(Actor)) :-
    physical_action(stand_up(Actor)),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Only one object count can exist"
%
% -person_holding_object(Actor, Object, OtherObjectCount) if
%   person_holding_object(Actor, Object, ObjectCount),
%   OtherObjectCount != ObjectCount
-holds(person_holding_object(Actor, Object, OtherObjectCount), timestep) :-
    holds(person_holding_object(Actor, Object, ObjectCount), timestep),
    max_object_count(MaxObjectCount),
    OtherObjectCount = 0..MaxObjectCount,
    OtherObjectCount != ObjectCount.

% ---------------------------------------------------------------------

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
    holds(person_holding_object(Actor, Object, ObjectCount), timestep).

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
%   person_max_holding_weight(Person, MaxWeight)
%   NewCarryWeight = Weight + CarryWeight,
%   NewCarryWeight >= MaxWeight
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
    holds(person_holding_object(Actor, Object, ObjectCount), timestep).

% "Cannot put down when we aren't holding anything"
%
% impossible put_down_object(Actor, Object) if
%   person_holding_object(Actor, Object, ObjectCount)
%   ObjectCount = 0
impossible(put_down_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(person_holding_object(Actor, Object, ObjectCount), timestep),
    ObjectCount = 0.

% ---------------------------------------------------------------------

% "Asking to put down decreases object count"
%
% ask_to_put_down_object(Actor, Person, Object)
%   causes person_holding_object(Person, Object, ObjectCount - 1)
%   if
%     person_holding_object(Person, Object, ObjectCount)
holds(person_holding_object(Person, Object, ObjectCount - 1), timestep + 1) :-
    person(Person),
    object(Object),
    occurs(ask_to_put_down_object(Actor, Person, Object), timestep),
    holds(person_holding_object(Person, Object, ObjectCount), timestep).

% "Cannot put down when they aren't holding anything"
%
% impossible ask_to_put_down_object(Actor, Person, Object) if
%   person_holding_object(Person, Object, ObjectCount)
%   ObjectCount = 0
impossible(ask_to_put_down_object(Actor, Person, Object), timestep) :-
    person(Actor),
    person(Person),
    object(Object),
    holds(person_holding_object(Person, Object, ObjectCount), timestep),
    ObjectCount = 0.

% ---------------------------------------------------------------------

% -object_turned_on(Location, Object, OtherObjectCount)
%   if object_turned_on(Location, Object, ObjectCount)
-holds(object_turned_on(Location, Object, OtherObjectCount), timestep) :-
    holds(object_turned_on(Location, Object, ObjectCount), timestep),
    max_object_count(MaxObjectCount),
    OtherObjectCount = 0..MaxObjectCount,
    OtherObjectCount != ObjectCount.

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

% impossible turn_on_object(Actor, Object) if
%   object_turned_on(Location, Object)
impossible(turn_on_object(Actor, Object), timestep) :-
    person(Actor),
    object(Object),
    holds(object_turned_on(Location, Object), timestep).

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

% ---------------------------------------------------------------------

% -object_location(Object, Location, OtherObjectCount)
%   if object_location(Object, Location, ObjectCount)
-holds(object_location(Object, Location, OtherObjectCount), timestep) :-
    holds(object_location(Object, Location, ObjectCount), timestep),
    max_object_count(MaxObjectCount),
    OtherObjectCount = 0..MaxObjectCount,
    OtherObjectCount != ObjectCount.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_description(timestep).

% TODO: Refactor policies to latest changes
% TODO: Add agent_action(Action)

% "Everyone must take their ID badge with them when moving"
%
% obl(pick_up_object(Actor, Object)) if
%   Object = id_badge(Actor),
%   -person_holding_object(Actor, Object),
%   occurs(move(Actor, ToLocation))
obl(pick_up_object(Actor, Object), timestep) :-
    agent(Actor),
    id_badge(Actor),
    Object = id_badge(Actor),
    occurs(move(Actor, ToLocation), timestep),
    -holds(person_holding_object(Actor, Object), timestep).

% "No one is permitted to carry an electronic device into a classified room"
%
% -permitted(move(Actor, ToLocation)) if
%   location_room(ToLocation, Room)
%   room_classified(Room)
%   person_holding_object(Actor, Object)
%   object_attribute(Object, electronic)
-permitted(move(Actor, ToLocation), timestep) :-
    agent(Actor),
    location_room(ToLocation, Room),
    room_classified(Room),
    holds(person_holding_object(Actor, Object), timestep),
    object_attribute(Object, electronic).

% "Normally, one must turn off the lights when leaving a room"
%
% lights_1(Actor, Object): normally obl(turn_off_object(Actor, Object)) if
%   occurs(move(Actor, ToLocation), timestep),
%   person_location(Actor, FromLocation),
%   location_room(ToLocation, NewRoom),
%   location_room(FromLocation, OldRoom),
%   NewRoom != OldRoom,
%   object(Object),
%   Object = light,
obl(turn_off_object(Actor, Object), timestep) :-
    agent(Actor),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_location(Actor, FromLocation), timestep),
    location_room(ToLocation, NewRoom),
    location_room(FromLocation, OldRoom),
    NewRoom != OldRoom,
    object(Object),
    Object = light,
    not abnormal(lights_1(Actor, Object), timestep),
    not -obl(turn_off_object(Actor, Object), timestep),
    not -permitted(turn_off_object(Actor, Object), timestep).  % Note: Our addition

% "Normally, one must not turn off the lights when leaving the main room"
%
% lights_2(Actor, Object): normally obl(-turn_off_object(Actor, Object)) if
%   occurs(move(Actor, ToLocation), timestep),
%   person_location(Actor, FromLocation),
%   location_room(ToLocation, NewRoom),
%   location_room(FromLocation, OldRoom),
%   NewRoom != OldRoom,
%   main_room(NewRoom),
%   object(Object),
%   Object = light,
obl(neg(turn_off_object(Actor, Object)), timestep) :-
    agent(Actor),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_location(Actor, FromLocation), timestep),
    location_room(ToLocation, NewRoom),
    location_room(FromLocation, OldRoom),
    NewRoom != OldRoom,
    main_room(NewRoom),
    object(Object),
    Object = light,
    not abnormal(lights_2(Actor, Object), timestep),
    not -obl(neg(turn_off_object(Actor, Object)), timestep),
    not permitted(turn_off_object(Actor, Object), timestep).  % Note: Our addition

% prefer(lights_2(Actor, Object), lights_1(Actor, Object))
abnormal(lights_1(Actor, Object), timestep) :-
    agent(Actor),
    % Condition of lights_2(Actor, Object)
    occurs(move(Actor, ToLocation), timestep),
    holds(person_location(Actor, FromLocation), timestep),
    location_room(ToLocation, NewRoom),
    location_room(FromLocation, OldRoom),
    NewRoom != OldRoom,
    main_room(NewRoom),
    object(Object),
    Object = light.

% "Normally, one must turn off the lights when leaving a room after hours"
%
% normally obl(-turn_off_object(Actor, Object)) if
%   occurs(move(Actor, ToLocation), timestep),
%   person_location(Actor, FromLocation),
%   location_room(ToLocation, NewRoom),
%   location_room(FromLocation, OldRoom),
%   NewRoom != OldRoom,
%   -time_business_hours,
%   object(Object),
%   Object = light,
obl(neg(turn_off_object(Actor, Object)), timestep) :-
    agent(Actor),
    occurs(move(Actor, ToLocation), timestep),
    holds(person_location(Actor, FromLocation), timestep),
    location_room(ToLocation, NewRoom),
    location_room(FromLocation, OldRoom),
    NewRoom != OldRoom,
    -holds(time_business_hours, timestep),
    object(Object),
    Object = light,
    not abnormal(lights_1(Actor, Object), timestep),
    not -obl(neg(turn_off_object(Actor, Object)), timestep),
    not permitted(turn_off_object(Actor, Object), timestep).  % Note: Our addition

% "Never turn off the lights when someone else is in the room"
%
% obl(-turn_off_lights(Actor, Object)) if
%   person_location(Person, Location),
%   Person != Actor,
%   object(Object),
%   Object = light,
obl(neg(turn_off_lights(Actor, Object)), timestep) :-
    agent(Actor),
    holds(person_location(Person, Location), timestep),
    Person != Actor,
    object(Object),
    Object = light.

% "Normally, no one is allowed to sit down in someone's cubicle"
%
% sit_down_cubical_1(Actor, Object): -permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   cubical(Location)
%   personal_space(Location, Person)
%   Person != Actor
-permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    cubical(Location),
    personal_space(Location, Person),
    Person != Actor,
    not abnormal(sit_down_cubical_1(Actor, Object), timestep),
    not permitted(sit_on_object(Actor, Object), timestep).

% "Normally, one is allowed to sit down in someone's cubicle if the owner of the cubicle is there"
%
% sit_down_cubical_2(Actor, Object) : permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   cubical(Location)
%   personal_space(Location, Person)
%   Person != Actor
%   person_location(Person, Location)
permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    cubical(Location),
    personal_space(Location, Person),
    Person != Actor,
    holds(person_location(Person, Location), timestep),
    not abnormal(sit_down_cubical_2(Actor, Object), timestep),
    not permitted(sit_on_object(Actor, Object), timestep).

% prefer(sit_down_cubical_2, sit_down_cubical_1)
abnormal(sit_down_cubical_1(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    cubical(Location),
    personal_space(Location, Person),
    Person != Actor,
    holds(person_location(Person, Location), timestep).

% "You are allowed to sit down in your own cubicle"
%
% permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   cubical(Location)
%   personal_space(Location, Person)
%   Person = Actor
permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    cubical(Location),
    personal_space(Location, Person),
    Person = Actor.

% "Normally, no one is allowed to sit down in someone's private office"
%
% sit_down_private_office_1(Actor, Object): -permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   private_office(Location)
%   personal_space(Location, Person)
%   Person != Actor
-permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    private_office(Location),
    personal_space(Location, Person),
    Person != Actor,
    not abnormal(sit_down_private_office_1(Actor, Object), timestep),
    not permitted(sit_on_object(Actor, Object), timestep).

% "Normally, one is allowed to sit down in someone's private office if the owner of the office is there"
%
% sit_down_private_office_2(Actor, Object) : permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   private_office(Location)
%   personal_space(Location, Person)
%   Person != Actor
%   person_location(Person, Location)
permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    private_office(Location),
    personal_space(Location, Person),
    Person != Actor,
    holds(person_location(Person, Location), timestep),
    not abnormal(sit_down_private_office_2(Actor, Object), timestep),
    not permitted(sit_on_object(Actor, Object), timestep).

% prefer(sit_down_private_office_2, sit_down_private_office_1)
abnormal(sit_down_private_office_1(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    private_office(Location),
    personal_space(Location, Person),
    Person != Actor,
    holds(person_location(Person, Location), timestep).

% "You are allowed to sit down in your own private office"
%
% permitted(sit_on_object(Actor, Object)) if
%   object_attribute(Object, sittable)
%   person_location(Actor, Location)
%   private_office(Location)
%   personal_space(Location, Person)
%   Person = Actor
permitted(sit_on_object(Actor, Object), timestep) :-
    agent(Actor),
    object_attribute(Object, sittable),
    holds(person_location(Actor, Location), timestep),
    private_office(Location),
    personal_space(Location, Person),
    Person = Actor.
