% Check_2.lp
% I = 1.
-weakly_compliant :-
    occurs(assume_command(c1, m1), 1),
    -permitted(assume_command(c1, m1), 1).

:-
    not -weakly_compliant.
