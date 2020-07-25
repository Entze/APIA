% I = 1.
-strongly_compliant :-
    occurs(assume_command(c1, m1), 1),
    not permitted(assume_command(c1, m1), 1).

:-
    not -strongly_compliant.
