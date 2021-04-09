% ---------------------------------------------------------------
#program observations_1.

% ---------------------------------------------------------------
#program observations_2.

% ---------------------------------------------------------------
#program observations_3.

% ---------------------------------------------------------------
#program observations_4.

% ---------------------------------------------------------------
#program observations_5.

% ---------------------------------------------------------------
#program observations_6.

happened(stop(Activity), Timestep) :-
    Timestep = 5,
    Activity = 1.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_7.

happened(start(Activity), Timestep) :-
    Timestep = 6,
    Activity = 3.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_8.

happened(knock_on_door(Actor, Door), Timestep) :-
    Timestep = 7,
    Actor = "Alice",
    Door = "d34".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 8,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_9.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 8,
    Actor = "Alice",
    Person = "Bob".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 9,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_10.

happened(stop(Activity), Timestep) :-
    Timestep = 9,
    Activity = 3.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 10,
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
#program observations_11.

happened(wait, Timestep) :-
    Timestep = 10.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 11,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_12.

happened(wait, Timestep) :-
    Timestep = 11.
