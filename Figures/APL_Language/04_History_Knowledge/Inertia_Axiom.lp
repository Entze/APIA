#const max_I = 1.

% If the value of a fluent is true at timestep I and we cannot otherwise show that it is false at timestep I + 1,
% then the value of the fluent is true at timestep I + 1
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

% If the value of a fluent is false at timestep I and we cannot otherwise show that it is true at timestep I + 1,
% then the value of the fluent is false at timestep I + 1
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
