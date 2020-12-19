% { a }.
{ a }.

% d: b_a +- a.
{ apply_cr_rule(d) } :-
    a.

b_a :-
    apply_cr_rule(d).

:~
    apply_cr_rule(d). [1@1, d]
