%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

