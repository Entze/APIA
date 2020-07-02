% Check_1.lp
-strongly_compliant :-
    occurs(A, I),
    not permitted(A, I),
    A = assume_command(c1, m1).

:-
    not -strongly_compliant.
