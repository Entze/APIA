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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% Starting ID for generated activities
#const ir = 1.

% goal(Goal) :-
%     Goal = %* ... *%,
%
% activity(Activity) :-
%     Activity = 1.
%
% activity_goal(Activity, ActivityGoal) :-
%     Activity = 1,
%     ActivityGoal = %* ... *%.
%
% activity_length(Activity, ActivityLength) :-
%     Activity = 1,
%     ActivityLength = #max{ ComponentIndex : activity_component(Activity, ComponentIndex, _) }.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 1,
%     Component = %* ... *%.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 2,
%     Component = %* ... *%.
%
% ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation
#program base.

-observed(bar(B), Timestep) :-
    Timestep = 0,
    b(B).

observed(baz(C), Timestep) :-
    Timestep = 0,
    c(C).
