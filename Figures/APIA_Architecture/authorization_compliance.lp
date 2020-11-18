% Since no actions occur in timestep 0, we define it as strongly compliant (as a base case)
auth_compliant(TimeStep) :-
    TimeStep = 0.

% Strongly compliant if for all occurs(Action), permitted(Action) is true
auth_compliant(TimeStep) :-
    auth_compliant(TimeStep - 1),
    permitted(Action, TimeStep) : occurs(Action, TimeStep), step(TimeStep).

auth_compliant :-
    auth_compliant(TimeStep) : step(TimeStep).

% Non-compliant if there exists occurs(Action) where permitted(Action) is false
-auth_compliant(TimeStep) :-
    step(TimeStep),
    occurs(Action, TimeStep),
    -permitted(Action, TimeStep).

-auth_compliant(TimeStep) :-
    -auth_compliant(TimeStep - 1),
    TimeStep > 0.

-auth_compliant :-
    -auth_compliant(_).

% Weakly compliant if auth_compliant is unknown
