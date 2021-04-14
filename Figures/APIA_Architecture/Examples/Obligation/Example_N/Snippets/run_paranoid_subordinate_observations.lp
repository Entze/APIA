% ---------------------------------------------------------------
#program observations_1.

% ---------------------------------------------------------------
#program observations_2.

happened(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

-observed(security_system_enabled, Timestep) :-
    Timestep = 2.

% ---------------------------------------------------------------
#program observations_3.

happened(wait, Timestep) :-
    Timestep = 2.

-observed(security_system_enabled, Timestep) :-
    Timestep = 3.

% ---------------------------------------------------------------
#program observations_4.

happened(wait, Timestep) :-
    Timestep = 3.

-observed(security_system_enabled, Timestep) :-
    Timestep = 4.

% ---------------------------------------------------------------
#program observations_5.

happened(wait, Timestep) :-
    Timestep = 4.

-observed(security_system_enabled, Timestep) :-
    Timestep = 5.

% ---------------------------------------------------------------
#program observations_6.

happened(wait, Timestep) :-
    Timestep = 5.

-observed(security_system_enabled, Timestep) :-
    Timestep = 6.

% ---------------------------------------------------------------
#program observations_7.

happened(wait, Timestep) :-
    Timestep = 6.

-observed(security_system_enabled, Timestep) :-
    Timestep = 7.

% ---------------------------------------------------------------
#program observations_8.

happened(wait, Timestep) :-
    Timestep = 7.

-observed(security_system_enabled, Timestep) :-
    Timestep = 8.

% ---------------------------------------------------------------
#program observations_9.

happened(wait, Timestep) :-
    Timestep = 8.

-observed(security_system_enabled, Timestep) :-
    Timestep = 9.

% ---------------------------------------------------------------
#program observations_10.

happened(wait, Timestep) :-
    Timestep = 9.

% ---------------------------------------------------------------
#program observations_11.

% ---------------------------------------------------------------
#program observations_12.
