% Inertia_Axiom.lp
#const max_I = 1.

val(FluentName, I + 1) :-
    val(FluentName, I),
    not -val(FluentName, I + 1),
    I < max_I,
    FluentName = (
        authorized(c1, m1);
        commands(c1, m1);
        colonel(c1);
        observer(c1)
    ).

-val(FluentName, I + 1) :-
    -val(FluentName, I),
    not val(FluentName, I + 1),
    I < max_I,
    FluentName = (
        authorized(c1, m1);
        commands(c1, m1);
        colonel(c1);
        observer(c1)
    ).
