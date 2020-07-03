% Check_1.lp
-strongly_compliant :-
    occurs(assume_command(c1, m1), I),
    not permitted(assume_command(c1, m1), I).

:-
    not -strongly_compliant.
