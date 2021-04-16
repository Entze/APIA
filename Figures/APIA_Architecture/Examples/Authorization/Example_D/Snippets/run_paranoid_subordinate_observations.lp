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

happened(wait, Timestep) :-
    Timestep = 5.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_7.

happened(wait, Timestep) :-
    Timestep = 6.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_8.

happened(wait, Timestep) :-
    Timestep = 7.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 8,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_9.

happened(wait, Timestep) :-
    Timestep = 8.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 9,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_10.

happened(start(Activity), Timestep) :-
    Timestep = 9,
    Activity = 5.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 10,
    Actor = "Alice",
    Person = "Bob".

% ---------------------------------------------------------------
#program observations_11.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 10,
    Actor = "Alice",
    Door = "d34".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 11,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_12.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 11,
    Actor = "Alice",
    Person = "Bob".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 12,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_13.

happened(stop(Activity), Timestep) :-
    Timestep = 12,
    Activity = 5.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 13,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_14.

happened(wait, Timestep) :-
    Timestep = 13.
