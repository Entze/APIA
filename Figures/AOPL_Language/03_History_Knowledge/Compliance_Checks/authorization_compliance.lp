#include "util.lp".

% Strongly compliant if for all occurs(Action), permitted(Action) is true
auth_compliant(I) :-
    auth_compliant(I - 1),
    permitted(Action, I),
    @is_positive(Action) = true : occurs(Action, I), step(I).

auth_compliant :-
    auth_compliant(I) : step(I).

% Non-compliant if there exists occurs(Action) where permitted(Action) is false
-auth_compliant(I) :-
    step(I),
    occurs(Action, I),
    -permitted(Action, I).

-auth_compliant(I) :-
    -auth_compliant(I - 1),
    I > 0.

-auth_compliant :-
    -auth_compliant(_).

% Weakly compliant if auth_compliant is unknown
