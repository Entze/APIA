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

% Intended action should be wait
%:-
%    not intended_action(wait, Timestep),
%    Timestep = 0.

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

happened(select(policy_compliant(greeted_by(Person, Actor))), Timestep) :-
    Timestep = 0,
    Person = "Bob",
    Actor = "Alice".

% Increment timestep

% "The agent always observes the truth value of his goal"
% (p. 36) of dissertation
-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 1,
    Person = "Bob",
    Actor = "Alice".



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

attempt(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

%--- Iteration 2: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_8.

happened(start(Activity), Timestep) :-
    Timestep = 1,
    Activity = 1.

% Increment timestep

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 2,
    Person = "Bob",
    Actor = "Alice".



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

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Alice",
    Door = "d12".

%--- Iteration 3: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_12.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 2,
    Actor = "Alice",
    Door = "d12".

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 3,
    Person = "Alice",
    Room = "r2".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 3,
    Person = "Bob",
    Actor = "Alice".



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

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Alice",
    Door = "d23".

%--- Iteration 4: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_16.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 3,
    Actor = "Alice",
    Door = "d23".

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 4,
    Person = "Alice",
    Room = "r3".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 4,
    Person = "Bob",
    Actor = "Alice".



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

attempt(move_through(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Alice",
    Door = "d34".

%--- Iteration 5: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_20.

happened(move_through(Actor, Door), Timestep) :-
    Timestep = 4,
    Actor = "Alice",
    Door = "d34".

% Increment timestep

observed(in_room(Person, Room), Timestep) :-
    Timestep = 5,
    Person = "Alice",
    Room = "r4".

-observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 5,
    Person = "Bob",
    Actor = "Alice".



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

attempt(greet(Actor, Person), Timestep) :-
    Timestep = 5,
    Actor = "Alice",
    Person = "Bob".

%--- Iteration 6: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_24.

happened(greet(Actor, Person), Timestep) :-
    Timestep = 5,
    Actor = "Alice",
    Person = "Bob".

% Increment timestep

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 6,
    Actor = "Alice",
    Person = "Bob".



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

attempt(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

%--- Iteration 7: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_28.

happened(stop(Activity), Timestep) :-
    Timestep = 6,
    Activity = 1.

% Increment timestep

observed(greeted_by(Person, Actor), Timestep) :-
    Timestep = 7,
    Person = "Bob",
    Actor = "Alice".



%--- Iteration 8: Step 1 (Interpret observations) ---%
#program test_29.

%--- Iteration 8: Step 2 (Find intended action) ---%
#program test_30.

interpretation(Step1UnobservedActions, Timestep) :-
    Step1UnobservedActions = 0,
    Timestep = 7.

% Intended action should be wait
%:-
%    not intended_action(wait, Timestep),
%    Timestep = 7.

%--- Iteration 8: Step 3 (Attempt the intended action) ---%
#program test_31.

attempt(wait, Timestep) :-
    Timestep = 7.

%--- Iteration 8: Step 4 (Observe actions, increment timestep, & observe fluents) ---%
% happened(Action, Timestep) and observed(Fluent, Timestep) are asserted by the agent's controller at this point
#program test_32.

happened(wait, Timestep) :-
    Timestep = 7.

% Increment timestep
