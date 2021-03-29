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
        @str_format("location_private_office_{}", 1);
    ).

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
        @str_format("location_private_office_{}", 1);
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
        @str_format("location_classified_conference_room_{}", RoomNumber);
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

% Doors are not necessarily two-way

door(FromLocation, ToLocation) :-
    door(ToLocation, FromLocation).

door(FromLocation, ToLocation) :-
    FromLocation = "location_outside_1",
    ToLocation = "location_inside_1".

door_has_lock(FromLocation, ToLocation) :-
    FromLocation = "location_outside_1",
    ToLocation = "location_inside_1".
