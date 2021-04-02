%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meeting(Meeting) :-
    Meeting = 1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

-observed(busy_working(Person), Timestep) :-
    Timestep = 0,
    Person = "Bob".

-observed(busy_working(Person), Timestep) :-
    Timestep = 0,
    Person = "Alice".

-observed(meeting_scheduled(Meeting), Timestep) :-
    Timestep = 0,
    meeting(Meeting).

-observed(meeting_classified(Meeting), Timestep) :-
    Timestep = 0,
    meeting(Meeting).

-observed(meeting_urgent(Meeting), Timestep) :-
    Timestep = 0,
    meeting(Meeting).

-observed(meeting_attendee(Meeting, Person), Timestep) :-
    Timestep = 0,
    meeting(Meeting),
    person(Person).

-observed(meeting_held(Meeting), Timestep) :-
    Timestep = 0,
    meeting(Meeting).

-observed(meeting_location(Meeting, Location), Timestep) :-
    Timestep = 0,
    meeting(Meeting),
    location(Location).

observed(current_meeting(Meeting), Timestep) :-
    Timestep = 0,
    Meeting = 1.
