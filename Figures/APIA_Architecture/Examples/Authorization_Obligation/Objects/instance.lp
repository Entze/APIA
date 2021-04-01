%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person_max_holding_weight(Person, MaxWeight) :-
    person(Person),
    MaxWeight = 2.

max_object_count(MaxObjectCount) :-
    MaxObjectCount = 12.

computer(Computer) :-
    Computer = 1.

cellphone(Cellphone) :-
    Cellphone = 1.

computer_has(Computer, cd_drive) :-
    computer(Computer).

location(computer(Computer), location(Location)) :-
    location(Location),
    computer(Computer),
    Computer = 1,
    Location = 2.

