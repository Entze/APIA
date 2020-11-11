%%%% Sanity checks %%%%
#program base.

:-
    invalid(_).

invalid(door(Door)) :-
    door(Door),
    not door_connects(Door, _).

invalid(door_connects(Door, DoorCount)) :-
    door(Door),
    DoorCount = #count{ Room : door_connects(Door, Room) },
    DoorCount != 2.
