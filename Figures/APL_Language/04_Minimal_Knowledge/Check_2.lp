% Check_2.lp
-weakly_compliant :-
    occurs(assume_command(c1, m1), I),
    -permitted(assume_command(c1, m1), I).

:-
    not -weakly_compliant.
