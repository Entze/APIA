% Usage: clingo --text FILE
#external a(X) : X = (abc;     ac;    ab;    a   ).
#external b(X) : X = (abc; bc;        ab; b      ).
#external c(X) : X = (abc; bc; ac; c             ).
#external d(X) : X = (abc; bc; ac; c; ab; b; a; d).

b_a :-
    b(X) : a(X).

c_a :-
    c(X) : a(X).

cb_a(X) :-
    c(X),
    b(X) : a(X).

c_ab :-
    c(X) : a(X), b(X).

dcb_a(X) :-
    d(X),
    c(X),
    b(X) : a(X).

dc_ab(X) :-
    d(X),
    c(X) : a(X), b(X).
