% Domains

room(Room) :-
    Room = ("r1"; "r2"; "r3"; "r4").

person(Person) :-
    Person = ("bob"; "alice").

holds(..., 0)
occurs(..., 0)
occurs(..., 1)

% Also check for unsatisfiable answer sets
