%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

location(Location) :-
    Location = (
        % Double-door building entry
        "location_outside_1";
        "location_inside_1";

        % Main room
        @str_format("location_office_space_{}", 1..11);
        @str_format("location_cubical_{}", 1..4);
        @str_format("location_private_office_{}", 1);
        @str_format("location_conference_room_{}", 1..2);

        % Hallway
        @str_format("location_hallway_{}", 1..3);

        % Second room
        @str_format("location_classified_office_space_{}", 1..6);
        @str_format("location_classified_conference_room_{}", 1);
        @str_format("location_classified_cubical_{}", 1..4)
    ).

cubical(Location) :-
    location(Location),
    Location = (
        @str_format("location_cubical_{}", 1..4);
        @str_format("location_classified_cubical_{}", 1..4)
    ).

private_office(Location) :-
    location(Location),
    Location = (
        @str_format("location_private_office_{}", 1)
    ).

personal_space(Location, Person) :-
    Location = @str_format("location_private_office_{}", 1),
    Person = "Alice".

% TODO: Add more personal_space(Location, Person)

% -----------------------------------------------------------------------

room(Room) :-
    Room = (
        "room_main";
        @str_format("room_conference_{}", 1..2);
        "room_hallway";
        "room_classified";
        @str_format("room_classified_conference_{}", 1)
    ).

location_room(Location, Room) :-
    location(Location),
    room(Room),
    Location = (
        @str_format("location_office_space_{}", 1..11);
        @str_format("location_cubical_{}", 1..4);
        @str_format("location_private_office_{}", 1)
    ),
    Room = "room_main".

location_room(Location, Room) :-
    location(Location),
    room(Room),
    RoomNumber = 1..2,
    Location = (
        @str_format("location_conference_room_{}", RoomNumber)
    ),
    Room = @str_format("room_conference_{}", RoomNumber).

location_room(Location, Room) :-
    location(Location),
    room(Room),
    Location = (
        @str_format("location_hallway_{}", 1..3)
    ),
    Room = "room_hallway".

location_room(Location, Room) :-
    location(Location),
    room(Room),
    RoomNumber = 1,
    Location = (
        @str_format("location_classified_conference_room_{}", RoomNumber)
    ),
    Room = @str_format("room_classified_conference_{}", RoomNumber).

location_room(Location, Room) :-
    location(Location),
    room(Room),
    Location = (
        @str_format("location_classified_office_space_{}", 1..6);
        @str_format("location_classified_cubical_{}", 1..4)
    ),
    Room = "room_classified".

conference_room(Room) :-
    room(Room),
    Room = (
        @str_format("location_conference_room_{}", 1..2);
        @str_format("location_classified_conference_room_{}", 1)
    ).

room_classified(Room) :-
    room(Room),
    Room = (
        "room_classified";
        @str_format("room_classified_conference_{}", 1)
    ).

% -----------------------------------------------------------------------

% Doors are normally, but not necessarily, two-way

door(FromLocation, ToLocation) :-
    door(ToLocation, FromLocation),
    not -door(FromLocation, ToLocation).

% -----------------------------------------------------------------------
% location_outside
% location_inside

door(FromLocation, ToLocation) :-
    FromLocation = "location_outside_1",
    ToLocation = "location_inside_1".

door_has_lock(FromLocation, ToLocation) :-
    FromLocation = "location_outside_1",
    ToLocation = "location_inside_1".

% -----------------------------------------------------------------------
% location_office_space

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 1),
    ToLocation = @str_format("location_office_space_{}", 2).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 2),
    ToLocation = @str_format("location_office_space_{}", 3).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 3),
    ToLocation = @str_format("location_office_space_{}", 4).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 4),
    ToLocation = @str_format("location_office_space_{}", 5).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 5),
    ToLocation = @str_format("location_office_space_{}", 6).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 6),
    ToLocation = @str_format("location_office_space_{}", 7).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 7),
    ToLocation = @str_format("location_office_space_{}", 8).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 8),
    ToLocation = @str_format("location_office_space_{}", 9).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 8),
    ToLocation = @str_format("location_office_space_{}", 11).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 9),
    ToLocation = @str_format("location_office_space_{}", 11).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 10),
    ToLocation = @str_format("location_office_space_{}", 1).

% -----------------------------------------------------------------------
% location_cubical

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 2),
    ToLocation = @str_format("location_cubical_{}", 1).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 3),
    ToLocation = @str_format("location_cubical_{}", 2).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 6),
    ToLocation = @str_format("location_cubical_{}", 3).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 7),
    ToLocation = @str_format("location_cubical_{}", 4).

% -----------------------------------------------------------------------
% location_private_office

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 4),
    ToLocation = @str_format("location_private_office_{}", 1).

% -----------------------------------------------------------------------
% location_conference_room

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 5),
    ToLocation = @str_format("location_conference_room_{}", 1).

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 8),
    ToLocation = @str_format("location_conference_room_{}", 1).

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 9),
    ToLocation = @str_format("location_conference_room_{}", 2).

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 10),
    ToLocation = @str_format("location_conference_room_{}", 2).

% -----------------------------------------------------------------------
% location_hallway

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_office_space_{}", 11),
    ToLocation = @str_format("location_hallway_{}", 1).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 1),
    ToLocation = @str_format("location_hallway_{}", 2).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 1),
    ToLocation = @str_format("location_hallway_{}", 3).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 2),
    ToLocation = @str_format("location_hallway_{}", 1).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 2),
    ToLocation = @str_format("location_hallway_{}", 3).

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 3),
    ToLocation = @str_format("location_classified_office_space_{}", 1).

door_has_lock(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_hallway_{}", 3),
    ToLocation = @str_format("location_classified_office_space_{}", 1).

% -----------------------------------------------------------------------
% location_classified_office_space

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 1),
    ToLocation = @str_format("location_classified_office_space_{}", 2).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 2),
    ToLocation = @str_format("location_classified_office_space_{}", 3).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 3),
    ToLocation = @str_format("location_classified_office_space_{}", 4).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 4),
    ToLocation = @str_format("location_classified_office_space_{}", 5).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 5),
    ToLocation = @str_format("location_classified_office_space_{}", 6).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 6),
    ToLocation = @str_format("location_classified_office_space_{}", 1).

% -----------------------------------------------------------------------
% location_classified_cubical

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 2),
    ToLocation = @str_format("location_classified_cubical_{}", 1).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 3),
    ToLocation = @str_format("location_classified_cubical_{}", 2).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 5),
    ToLocation = @str_format("location_classified_cubical_{}", 3).

path(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 6),
    ToLocation = @str_format("location_classified_cubical_{}", 4).

% -----------------------------------------------------------------------
% location_classified_conference_room

door(FromLocation, ToLocation) :-
    FromLocation = @str_format("location_classified_office_space_{}", 4),
    ToLocation = @str_format("location_classified_conference_room_{}", 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation
#program base.

observed(person_location(Person, Location), Timestep) :-
    Timestep = 0,
    person(Person),
    location(Location),
    Person = "Alice",
    Location = "location_outside_1".

observed(person_location(Person, Location), Timestep) :-
    Timestep = 0,
    person(Person),
    location(Location),
    Person = "Bob",
    Location = @str_format("location_private_office_{}", 1).

-observed(door_locked(FromLocation, ToLocation), Timestep) :-
    Timestep = 0,
    door(FromLocation, ToLocation),
    not door_has_lock(FromLocation, ToLocation).

observed(door_locked(FromLocation, ToLocation), Timestep) :-
    Timestep = 0,
    door_has_lock(FromLocation, ToLocation).

observed(door_autolock_countdown(FromLocation, ToLocation, TimestepsLeft), Timestep) :-
    Timestep = 0,
    door_has_lock(FromLocation, ToLocation),
    TimestepsLeft = 0.

observed(time(Hour, Minute), Timestep) :-
    Timestep = 0,
    Hour = 8,
    Minute = 0.
