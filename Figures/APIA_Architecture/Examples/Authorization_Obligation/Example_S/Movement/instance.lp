%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

location(Location) :-
    Location = (1).

cubical(Location) :-
    location(Location),
    Location = (1).

private_office(Location) :-
    location(Location),
    Location = (1).

% -----------------------------------------------------------------------

room(Room) :-
    Room = ("main").

location_room(Location, Room) :-
    location(Location),
    room(Room),
    Location = 1,
    Room = 1.

conference_room(Room) :-
    room(Room),
    Room = (2; 3).

classification(room(Room), Classification) :-
    room(Room),
    Classification = "Secret".

% -----------------------------------------------------------------------

path(Location1, Location2) :-
    Location1 = 1,
    Location2 = 2.

% Doors are not necessarily two-way
door(Location1, Location2) :-
    Location1 = 1,
    Location2 = 2.

door_has_lock(Location1, Location2) :-
    Location1 = 1,
    Location2 = 2.
