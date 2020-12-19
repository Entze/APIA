% { a }.
{ a }.

% d1: b_a +- a.
{ apply_cr_rule(d1) } :-
    a.

b_a :-
    apply_cr_rule(d1).

:~
    apply_cr_rule(d1). [1@1, d1]

% d2: c_a +- a.
{ apply_cr_rule(d2) } :-
    a.

c_a :-
    apply_cr_rule(d2).

:~
    apply_cr_rule(d2). [1@1, d2]

% prefer(d2, d1)
:~
    not apply_cr_rule(d2),
    apply_cr_rule(d1). [1@2, d2, d1]

% b_a :- c_a
b_a :-
    c_a.

% :- not b_a.
:-
    not b_a.
