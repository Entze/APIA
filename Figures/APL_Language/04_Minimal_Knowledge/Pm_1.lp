% Pm_1.lp
% I = 1.
-permitted(assume_command(c1, m1), 1) :-
    authorized(c1, m1, 1),
    not ab(d1, 1),
    not permitted(assume_command(c1, m1), 1).

permitted(assume_command(c1, m1), 1) :-
    colonel(c1, 1),
    not ab(d2, 1),
    not -permitted(assume_command(c1, m1), 1).

ab(d1, 1) :-
    colonel(c1, 1).

-permitted(authorize(c1, m1), 1) :-
    observer(c1, 1).
