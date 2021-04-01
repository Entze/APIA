%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person_max_holding_weight(Person, MaxWeight) :-
    person(Person),
    MaxWeight = 2.

max_object_count(MaxObjectCount) :-
    MaxObjectCount = 12.
