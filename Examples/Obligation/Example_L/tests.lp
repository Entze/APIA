% See p. 74 of dissertation for AIA control loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Expected sequence %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%--- (Initial observations) ---%
% See instance.lp

%--- Iteration 1: Step 1 (Interpret observations) ---%
#program test_1.

% There should be none

%--- Iteration 1: Step 2 (Find intended action) ---%
#program test_2.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 0.

%--- Iteration 1: Step 3 (Attempt the intended action) ---%
#program test_3.

attempt(wait, Timestep) :-
    Timestep = 0.

%--- Iteration 1: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_4.

% "The agent always observes the results of his attempts to perform actions"
% (p. 36, p. 51) of dissertation
%   There is no happened(...) :- attempt(...) rule.
happened(wait, Timestep) :-
    Timestep = 0.

happened(select(Goal), Timestep) :-
    Goal = policy_compliant(security_system_enabled),
    Timestep = 0.

% Increment timestep

% "The agent always observes the truth value of his goal"
% (p. 36) of dissertation
-observed(Goal, Timestep) :-
    Goal = policy_compliant(security_system_enabled),
    Timestep = 1.



%--- Iteration 2: Step 1 (Interpret observations) ---%
#program test_5.

% active_goal(greeted_by("Bob", "Alice")) should be true

%--- Iteration 2: Step 2 (Find intended action) ---%
#program test_6.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 1.

% Intended action should be start(1)

%--- Iteration 2: Step 3 (Attempt the intended action) ---%
#program test_7.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 1.

%--- Iteration 2: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_8.

happened(Action, Timestep) :-
    Timestep = 1.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 2.



%--- Iteration 3: Step 1 (Interpret observations) ---%
#program test_9.

%--- Iteration 3: Step 2 (Find intended action) ---%
#program test_10.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 2.

% Intended action should be move_through("Alice", "d12")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 2,
%    Actor = "Alice",
%    Door = "d12".

%--- Iteration 3: Step 3 (Attempt the intended action) ---%
#program test_11.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 2.

%--- Iteration 3: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_12.

happened(Action, Timestep) :-
    Timestep = 2.

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 3,
    Person = "Alice",
    Room = "r2".

-observed(Goal, Timestep) :-
    Timestep = 3.



%--- Iteration 4: Step 1 (Interpret observations) ---%
#program test_13.

%--- Iteration 4: Step 2 (Find intended action) ---%
#program test_14.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 3.

% Intended action should be move_through("Alice", "d23")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 3,
%    Actor = "Alice",
%    Door = "d23".

%--- Iteration 4: Step 3 (Attempt the intended action) ---%
#program test_15.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 3.

%--- Iteration 4: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_16.

happened(Action, Timestep) :-
    Timestep = 3.

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 4,
    Person = "Alice",
    Room = "r3".

-observed(Goal, Timestep) :-
    Timestep = 4.



%--- Iteration 5: Step 1 (Interpret observations) ---%
#program test_17.

%--- Iteration 5: Step 2 (Find intended action) ---%
#program test_18.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 4.

% Intended action should be move_through("Alice", "d34")
%:-
%    not intended_action(move_through(Actor, Door), Timestep),
%    Timestep = 4,
%    Actor = "Alice",
%    Door = "d23".

%--- Iteration 5: Step 3 (Attempt the intended action) ---%
#program test_19.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 4.

%--- Iteration 5: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_20.

happened(Action, Timestep) :-
    Timestep = 4.

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Alice",
    Room = "r4".

-observed(Goal, Timestep) :-
    Timestep = 5.



%--- Iteration 6: Step 1 (Interpret observations) ---%
#program test_21.

%--- Iteration 6: Step 2 (Find intended action) ---%
#program test_22.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 5.

% Intended action should be greet("Alice", "Bob")
%:-
%    not intended_action(greet(Actor, Person), Timestep),
%    Timestep = 5,
%    Actor = "Alice",
%    Person = "Bob".

%--- Iteration 6: Step 3 (Attempt the intended action) ---%
#program test_23.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 5.

%--- Iteration 6: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_24.

happened(Action, Timestep) :-
    Timestep = 5.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 6.



%--- Iteration 7: Step 1 (Interpret observations) ---%
#program test_25.

%--- Iteration 7: Step 2 (Find intended action) ---%
#program test_26.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 6.

% Intended action should be stop(1)
%:-
%    not intended_action(stop(Activity), Timestep),
%    Timestep = 6,
%    Activity = 1.

%--- Iteration 7: Step 3 (Attempt the intended action) ---%
#program test_27.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 6.

%--- Iteration 7: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_28.

happened(Action, Timestep) :-
    Timestep = 6.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 7.



%--- Iteration 8: Step 1 (Interpret observations) ---%
#program test_29.

%--- Iteration 8: Step 2 (Find intended action) ---%
#program test_30.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 7.

% Intended action should be knock_on_door("Alice", "d34")

%--- Iteration 8: Step 3 (Attempt the intended action) ---%
#program test_31.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 7.

%--- Iteration 8: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_32.

happened(Action, Timestep) :-
    Timestep = 7.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 8.



%--- Iteration 9: Step 1 (Interpret observations) ---%
#program test_33.

%--- Iteration 9: Step 2 (Find intended action) ---%
#program test_34.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 8.

% Intended action should be greet("Alice", "Bob")

%--- Iteration 9: Step 3 (Attempt the intended action) ---%
#program test_35.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 8.

%--- Iteration 9: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_36.

happened(Action, Timestep) :-
    Timestep = 8.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 9.



%--- Iteration 10: Step 1 (Interpret observations) ---%
#program test_37.

%--- Iteration 10: Step 2 (Find intended action) ---%
#program test_38.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 9.

% Intended action should be stop(2)

%--- Iteration 10: Step 3 (Attempt the intended action) ---%
#program test_39.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 9.

%--- Iteration 10: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_40.

happened(Action, Timestep) :-
    Timestep = 9.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 10.



%--- Iteration 11: Step 1 (Interpret observations) ---%
#program test_41.

%--- Iteration 11: Step 2 (Find intended action) ---%
#program test_42.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 10.

% Intended action should be wait
%:-
%    not intended_action(stop(Activity), Timestep),
%    Timestep = 6,
%    Activity = 1.

%--- Iteration 11: Step 3 (Attempt the intended action) ---%
#program test_43.

% Should be unsatisfiable until we observe happened/2.
% See (p. 60) of dissertation

attempt(Action, Timestep) :-
    Timestep = 10.

%--- Iteration 11: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_44.

happened(Action, Timestep) :-
    Timestep = 10.

% Increment timestep

-observed(Goal, Timestep) :-
    Timestep = 11.



%--- Iteration 12: Step 1 (Interpret observations) ---%
#program test_45.

%--- Iteration 12: Step 2 (Find intended action) ---%
#program test_46.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 11.

% Intended action should be wait
%:-
%    not intended_action(wait, Timestep),
%    Timestep = 7.

%--- Iteration 12: Step 3 (Attempt the intended action) ---%
#program test_47.

attempt(Action, Timestep) :-
    Timestep = 11.

%--- Iteration 12: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_48.

happened(Action, Timestep) :-
    Timestep = 11.

% Increment timestep
