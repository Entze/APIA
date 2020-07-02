% Check_2.lp
-weakly_compliant :-
    occurs(A, I),
    -permitted(A, I),
    A = assume_command(c1, m1).

:-
    not -weakly_compliant.
