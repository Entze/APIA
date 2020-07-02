% Pm.lp
-permitted(assume_command(c1, m1), I) :-
    authorized(c1, m1, I),
    not ab(d1, I),
    not permitted(assume_command(c1, m1), I).

permitted(assume_command(c1, m1), I) :-
    colonel(c1, I),
    not ab(d2, I),
    not -permitted(assume_command(c1, m1), I).

ab(d1, I) :-
    colonel(c1, I).

-permitted(authorize(c1, m1), I) :-
    observer(c1, I).
