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

% TODO: Troubleshoot why it sometimes intends start(6). It is non-deterministic
happened(start(Activity), Timestep) :-
    Timestep = 5,
    Activity = 7.

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_7.

happened(unlock_door(Actor, Door), Timestep) :-
    Timestep = 6,
    Actor = "Alice",
    Door = "d34".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_8.

happened(move_through(Actor, Door), Timestep) :-
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
    Activity = 7.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 10,
    Person = "Bob",
    Actor = "Alice".

% ---------------------------------------------------------------
#program observations_11.

happened(wait, Timestep) :-
    Timestep = 10.

% ---------------------------------------------------------------
#program observations_12.

happened(wait, Timestep) :-
    Timestep = 11.

% ---------------------------------------------------------------
#program observations_13.

happened(wait, Timestep) :-
    Timestep = 12.

% ---------------------------------------------------------------
#program observations_14.

happened(wait, Timestep) :-
    Timestep = 13.
