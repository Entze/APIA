% (Universal CR-rule weak constraint)
:~
    apply_cr_rule(D).
    [1@1, apply_cr_rule(D)]

% (Universal CR-prefer weak constraint)
:~
    cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@2, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

% d1: a +- .
{ apply_cr_rule(d1) }.

a :-
    apply_cr_rule(d1).

% d2: b +- .
{ apply_cr_rule(d2) }.

b :-
    apply_cr_rule(d2).

% d3: b' +- b.
{ apply_cr_rule(d3) } :-
    b.

b' :-
    apply_cr_rule(d3).

% d4: b'' +- b'.
{ apply_cr_rule(d4) } :-
    b'.

b'' :-
    apply_cr_rule(d4).

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
cr_prefer(d4, d1) :-
    % Condition of d4
    b'.

    % Condition of d1
    % (none)
