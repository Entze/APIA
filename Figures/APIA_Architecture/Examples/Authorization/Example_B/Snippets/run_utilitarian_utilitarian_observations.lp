#program observations_1.

#program observations_2.

#program observations_3.

#program observations_4.

#program observations_5.

#program observations_6.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 5,
    Actor = "Alice",
    Person = "Bob".

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Person = "Bob",
    Actor = "Alice".

#program observations_7.

happened(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".

#program observations_8.

happened(wait, Timestep) :-
    Timestep = 7.

#program observations_9.

happened(wait, Timestep) :-
    Timestep = 8.

#program observations_10.

happened(wait, Timestep) :-
    Timestep = 9.

#program observations_11.

happened(wait, Timestep) :-
    Timestep = 10.

#program observations_12.

happened(wait, Timestep) :-
    Timestep = 11.
