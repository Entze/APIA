%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

room(Room) :-
    Room = ("r1"; "r2"; "r3"; "r4").

door(Door) :-
    Door = ("d12"; "d23"; "d34").

person(Person) :-
    Person = ("Alice"; "Bob").

agent(Agent) :-
    Agent = "Alice".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

private_office(Room) :-
    Room = "r4".

supervisor_to(Boss, Person) :-
    Boss = "Bob",
    Person = "Alice".

door_connects(Door, Room) :-
    Door = "d12",
    Room = ("r1"; "r2").

door_connects(Door, Room) :-
    Door = "d23",
    Room = ("r2"; "r3").

door_connects(Door, Room) :-
    Door = "d34",
    Room = ("r3"; "r4").

door_has_lock(Door) :-
    Door = "d34".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Starting ID for generated activities
#const ir = 5.

goal(Goal) :-
    Goal = security_system_enabled.

% ---------------------------------------------------------------

activity_goal(Activity, ActivityGoal) :-
    Activity = 1,
    ActivityGoal = policy_compliant(security_system_enabled).

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 1,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r1".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d12".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 2,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r2".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d23".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 3,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r3".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 3,
    Component = unlock_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 4,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 5,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r4".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 5,
    Component = lock_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 6,
    Component = enable_security_system(Actor),
    Actor = "Alice".

% ---------------------------------------------------------------

activity_goal(Activity, ActivityGoal) :-
    Activity = 2,
    ActivityGoal = policy_compliant(security_system_enabled).

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 1,
    Component = enable_security_system(Actor),
    Actor = "Alice".

% ---------------------------------------------------------------

activity_goal(Activity, ActivityGoal) :-
    Activity = 3,
    ActivityGoal = policy_compliant(security_system_enabled).

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 1,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r1".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d12".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 2,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r2".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d23".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 3,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r3".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 3,
    Component = unlock_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 4,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 5,
    Component = turn_lights_off(Actor, Room),
    Actor = "Alice",
    Room = "r4".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 5,
    Component = ignore_obl(neg(turn_lights_off(Actor, Room))),
    Actor = "Alice",
    Room = "r4".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 5,
    Component = lock_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 6,
    Component = enable_security_system(Actor),
    Actor = "Alice".

% ---------------------------------------------------------------

activity_goal(Activity, ActivityGoal) :-
    Activity = 4,
    ActivityGoal = policy_compliant(security_system_enabled).

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = enable_security_system(Actor),
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = ignore_not_permitted(enable_security_system(Actor)),
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = ignore_obl(neg(enable_security_system(Actor))),
    Actor = "Alice".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Alice",
    Room = "r1".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Bob",
    Room = "r4".

observed(room_lights_on(Room), Timestep) :-
    Timestep = 0,
    room(Room).

-observed(security_system_enabled, Timestep) :-
    Timestep = 0.
