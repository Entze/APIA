% d1: a +- .
{ apply_cr_rule(d1) }.

a :-
    apply_cr_rule(d1).

:~
    apply_cr_rule(d1). [1@1, d1]

% d2: b +- .
{ apply_cr_rule(d2) }.

b :-
    apply_cr_rule(d2).

:~
    apply_cr_rule(d2). [1@1, d2]

% d3: b' +- b.
{ apply_cr_rule(d3) } :-
    b.

b' :-
    apply_cr_rule(d3).

:~
    apply_cr_rule(d3). [1@1, d3]

% d4: b'' +- b'.
{ apply_cr_rule(d4) } :-
    b'.

b'' :-
    apply_cr_rule(d4).

:~
    apply_cr_rule(d4). [1@1, d4]

% c :- a.
c :-
    a.

% c :- b''.
c :-
    b''.

% :- not c.
:-
    not c.

% prefer(d4, d1)
:~
    % Condition of d4
    b',

    % Condition of d1
    % (none)

    not apply_cr_rule(d4),
    apply_cr_rule(d1). [1@2, d4, d1]
