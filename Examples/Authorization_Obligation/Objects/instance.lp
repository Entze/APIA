%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person_max_holding_weight(Person, MaxWeight) :-
    person(Person),
    MaxWeight = 2.

max_object_count(MaxObjectCount) :-
    MaxObjectCount = 12.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

% TODO: Add objects at locations
observed(object_location(Object, Location, ObjectCount), Timestep) :-
    Timestep = 0,
    object(Object),
    location(Location),
    ObjectCount = 0.

observed(person_holding_object(Person, Object, ObjectCount), Timestep) :-
    Timestep = 0,
    person(Person),
    object_attribute(Object, holdable),
    ObjectCount = 0.

observed(object_turned_on(Location, Object, ObjectCount), Timestep) :-
    Timestep = 0,
    location(Location),
    object_attribute(Object, power),
    ObjectCount = 0.
