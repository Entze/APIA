%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

room(Room) :-
    Room = ("r1"; "r2"; "r3"; "r4").

door(Door) :-
    Door = ("d12"; "d23"; "d34").

person(Person) :-
    Person = ("Bob"; "Alice").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% move_through(Actor, Door)
agent_action(move_through(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor = "Bob".

exogenous_action(move_through(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor != "Bob".

% lock_door(Actor, Door)
agent_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor = "Bob".

exogenous_action(lock_door(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor != "Bob".

% unlock_door(Actor, Door)
agent_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor = "Bob".

exogenous_action(unlock_door(Actor, Door)) :-
    person(Actor),
    door(Door),
    Actor != "Bob".

% greet(Actor, Person)
agent_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person,
    Actor = "Bob".

exogenous_action(greet(Actor, Person)) :-
    person(Actor),
    person(Person),
    Actor != Person,
    Actor != "Bob".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Starting ID for generated activities
#const ir = 2.

goal(Goal) :-
    Goal = greeted_by(Person, Actor),
    Person = "Alice",
    Actor = "Bob".

activity(Activity) :-
    Activity = 1.

activity_goal(Activity, ActivityGoal) :-
    Activity = 1,
    ActivityGoal = greeted_by(Person, Actor),
    Person = "Alice",
    Actor = "Bob".

activity_length(Activity, ActivityLength) :-
    Activity = 1,
    ActivityLength = #max{ ComponentIndex : activity_component(Activity, ComponentIndex, _) }.

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d12".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d23".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 3,
    Component = move_through(Actor, Door),
    Actor = "Bob",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 4,
    Component = greet(Actor, Person),
    Actor = "Bob",
    Person = "Alice".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

-observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d12".

-observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d23".

-observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d34".

-observed(door_locked(Door), Timestep) :-
    Timestep = 0,
    Door = "d34".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Bob",
    Room = "r1".

observed(in_room(Person, Room), Timestep) :-
    Timestep = 0,
    Person = "Alice",
    Room = "r4".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 0,
    person(Person),
    person(Actor),
    Person != Actor.

%--- Theory of Intentions ---%

-observed(active_goal(Goal), Timestep) :-
    Timestep = 0,
    fluent(inertial, active_goal(Goal)).

observed(activity_status(Activity, ActivityIndex), Timestep) :-
    Timestep = 0,
    fluent(inertial, activity_status(Activity, ActivityIndex)),
    ActivityIndex = -1.

% TODO: Look at (p. 41) of dissertation
-observed(next_name(Activity), Timestep) :-
    Timestep = 0,
    fluent(inertial, next_name(Activity)),
    Activity != ir.
