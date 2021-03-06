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
    Goal = greeted_by(Person, Actor),
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
%
% Move through and greet

activity_goal(Activity, ActivityGoal) :-
    Activity = 1,
    ActivityGoal = policy_compliant(greeted_by(Person, Actor)),
    Person = "Bob",
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d12".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d23".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 3,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 1,
    ComponentIndex = 4,
    Component = greet(Actor, Person),
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
%
% Move through, knock on door, and greet

activity_goal(Activity, ActivityGoal) :-
    Activity = 2,
    ActivityGoal = policy_compliant(greeted_by(Person, Actor)),
    Person = "Bob",
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 1,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d12".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 2,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d23".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 3,
    Component = move_through(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 4,
    Component = knock_on_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 2,
    ComponentIndex = 5,
    Component = greet(Actor, Person),
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
%
% Knock on door and greet

activity_goal(Activity, ActivityGoal) :-
    Activity = 3,
    ActivityGoal = policy_compliant(greeted_by(Person, Actor)),
    Person = "Bob",
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 1,
    Component = knock_on_door(Actor, Door),
    Actor = "Alice",
    Door = "d34".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 3,
    ComponentIndex = 2,
    Component = greet(Actor, Person),
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
%
% Greet in spite of policy

activity_goal(Activity, ActivityGoal) :-
    Activity = 4,
    ActivityGoal = policy_compliant(greeted_by(Person, Actor)),
    Person = "Bob",
    Actor = "Alice".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = greet(Actor, Person),
    Actor = "Alice",
    Person = "Bob".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = ignore_not_permitted(greet(Actor, Person)),
    Actor = "Alice",
    Person = "Bob".

activity_component(Activity, ComponentIndex, Component) :-
    Activity = 4,
    ComponentIndex = 1,
    Component = ignore_neg_permitted(greet(Actor, Person)),
    Actor = "Alice",
    Person = "Bob".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

-observed(door_locked(Door), Timestep) :-
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

-observed(busy_working(Person), Timestep) :-
    Timestep = 0,
    Person = ("Bob"; "Alice").

-observed(knocked_on_door(Door), Timestep) :-
    Timestep = 0,
    door(Door).

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 0,
    person(Person),
    person(Actor),
    Person != Actor.
