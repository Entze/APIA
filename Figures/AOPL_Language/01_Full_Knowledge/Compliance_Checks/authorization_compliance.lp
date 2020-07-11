#include "util.lp".

% Strongly compliant if for all occurs(Action), permitted(Action) is true
auth_compliant :-
    permitted(Action),
    @is_positive(Action) = true : occurs(Action).

% Non compliant if there exists occurs(Action) where permitted(Action) is false
-auth_compliant :-
    occurs(Action),
    -permitted(Action).

% Weakly compliant if auth_compliant/0 is unknown
