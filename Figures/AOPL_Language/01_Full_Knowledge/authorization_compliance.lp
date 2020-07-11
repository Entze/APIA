auth_strongly_compliant :-
    permitted(Action),
    @is_positive(Action) = true : occurs(Action).

auth_weakly_compliant :-
    not -permitted(Action),
    @is_positive(Action) = true : occurs(Action).

auth_non_compliant :-
    occurs(Action),
    -permitted(Action).

-auth_strongly_compliant :-
    auth_non_compliant.

-auth_weakly_compliant :-
    auth_non_compliant.

-auth_non_compliant :-
    auth_weakly_compliant.

-auth_non_compliant :-
    auth_strongly_compliant.
