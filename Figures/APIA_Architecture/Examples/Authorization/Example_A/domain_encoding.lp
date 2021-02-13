%%%% Domains %%%%

% step(Timestep)

% room(Room)
% door(Door)
% person(Person)

%%%% Statics %%%%

% door_connects(Door, Room)
% door_has_lock(Door)

%%%% Fluents %%%%

% door_locked(Door)
fluent(inertial, door_locked(Door)) :-
    door(Door).

% in_room(Person, Room)
fluent(inertial, in_room(Person, Room)) :-
    person(Person),
    room(Room).

% greeted_by(Person, Actor)
fluent(inertial, greeted_by(Person, Actor)) :-
    person(Person),
    person(Actor),
    Person != Actor.

%%%% Actions %%%%

% move_through(Actor, Door)
physical_agent_action(move_through(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(move_through(Actor, Door)) :-
    person(Actor),
    door(Door).

% lock_door(Actor, Door)
physical_agent_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% unlock_door(Actor, Door)
physical_agent_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

physical_exogenous_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door).

% greet(Actor, Person)
physical_agent_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

physical_exogenous_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person.

%%%% Action descriptions %%%%

% move_through(Actor, Door) causes in_room(Actor, ToRoom)
%   if in_room(Actor, FromRoom), door_connects(Door, FromRoom),
%      ToRoom != FromRoom
holds(in_room(Actor, ToRoom), Timestep + 1) :-
    step(Timestep),
    occurs(move_through(Actor, Door), Timestep),
    door_connects(Door, ToRoom),
    door_connects(Door, FromRoom),
    ToRoom != FromRoom,
    holds(in_room(Actor, FromRoom), Timestep).

% -in_room(Actor, FromRoom) if in_room(Actor, ToRoom)
-holds(in_room(Actor, FromRoom), Timestep) :-
    room(FromRoom),
    holds(in_room(Actor, ToRoom), Timestep),
    FromRoom != ToRoom.

% impossible move_through(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(move_through(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% lock_door(Actor, Door) causes door_locked(Door)
holds(door_locked(Door), Timestep + 1) :-
    step(Timestep),
    occurs(lock_door(Actor, Door), Timestep).

% impossible lock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(lock_door(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% unlock_door(Actor, Door) causes -door_locked(Door)
-holds(door_locked(Door), Timestep + 1) :-
    step(Timestep),
    occurs(unlock_door(Actor, Door), Timestep).

% impossible unlock_door(Actor, Door)
%   if in_room(Actor, Room), not door_connects(Door, Room)
-occurs(unlock_door(Actor, Door), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, Room), Timestep),
    door(Door),
    not door_connects(Door, Room).

% greet(Actor, Person) causes greeted_by(Person, Actor)
holds(greeted_by(Person, Actor), Timestep + 1) :-
    step(Timestep),
    occurs(greet(Actor, Person), Timestep).

% impossible greet(Actor, Person)
%   if in_room(Actor, ActorRoom), in_room(Person, PersonRoom),
%      ActorRoom != PersonRoom.
-occurs(greet(Actor, Person), Timestep) :-
    step(Timestep),
    holds(in_room(Actor, ActorRoom), Timestep),
    holds(in_room(Person, PersonRoom), Timestep),
    ActorRoom != PersonRoom.

%%%% Activities %%%%

goal(Goal) :-
    Goal = greeted_by("Bob", "Alice").

activity(Activity) :-
    Activity = 1.

goal(Activity, ActivityGoal) :-
    Activity = 1,
    ActivityGoal = greeted_by("Alice", "Bob").

length(Activity, ActivityLength) :-
    Activity = 1,
    ActivityLength = #max{ ComponentIndex : component(Activity, ComponentIndex, _) }.

component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d12".

component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d23".

component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 3,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d34".

component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 4,
    Component = greet(Actor, Person),
    Actor = "Bob",
    Person = "Alice".

%%%% Authorization policy %%%%

% "Anyone is allowed to move from any room to any room"
%
% permitted(move_through(Actor, Door))
permitted(move_through(Actor, Door), Timestep) :-
    step(Timestep),
    person(Actor),
    door(Door).

% "Anyone is allowed to greet a coworker"
%
% permitted(greet(Actor, Person))
permitted(greet(Actor, Person), Timestep) :-
    step(Timestep),
    person(Actor),
    person(Person),
    Actor != Person.
