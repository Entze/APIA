% Pm_1.lp
-permitted(assume_command(cI, mI), I) :-
    val(authorized(cI, mI), I),
    not ab(dI, I),
    not permitted(assume_command(cI, mI), I).

permitted(assume_command(cI, mI), I) :-
    val(colonel(cI), I),
    not ab(d2, I),
    not -permitted(assume_command(cI, mI), I).

ab(dI, I) :-
    val(colonel(cI), I).

-permitted(authorize(cI, mI), I) :-
    val(observer(cI), I).
