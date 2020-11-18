#include "util.lp".

% Strongly compliant if for all occurs(Action), permitted(Action) is true
auth_compliant(TimeStep) :-
    auth_compliant(TimeStep - 1),
    permitted(Action, TimeStep),
    @is_positive(Action) = true : occurs(Action, TimeStep), step(TimeStep).

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
