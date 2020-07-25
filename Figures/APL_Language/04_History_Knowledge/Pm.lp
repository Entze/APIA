-permitted(assume_command(c1, m1), I) :-
    val(authorized(c1, m1), I),
    not ab(dI, I),
    not permitted(assume_command(c1, m1), I).

permitted(assume_command(c1, m1), I) :-
    val(colonel(c1), I),
    not ab(d2, I),
    not -permitted(assume_command(c1, m1), I).

ab(dI, I) :-
    val(colonel(c1), I).

-permitted(authorize(c1, m1), I) :-
    val(observer(c1), I).
