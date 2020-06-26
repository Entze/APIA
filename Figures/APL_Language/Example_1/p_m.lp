% p_m.lp
-permitted(assume_command(c1, m1)) :-
    authorized(c1, m1),
    not ab(d1),
    not permitted(assume_command(c1, m1)).

permitted(assume_command(c1, m1)) :-
    colonel(c1),
    not ab(d2),
    not -permitted(assume_command(c1, m1)).

ab(d1) :-
    colonel(c1).

-permitted(authorize(c1, m1)) :-
    observer(c1).
