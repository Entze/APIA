%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(fluent(FluentType, Fluent), Reason) :-
    fluent(FluentType, Fluent),
    FluentType != defined,
    FluentType != inertial,
    Reason = "Invalid FluentType".

invalid(holds(Fluent, Timestep), Reason) :-
    holds(Fluent, Timestep),
    not fluent(_, Fluent),
    Reason = "Fluent is not defined in fluent/2".

invalid(occurs(Action, Timestep), Reason) :-
    occurs(Action, Timestep),
    not action(Action),
    Reason = "Action is not defined in action/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(action(Action), Reason) :-
    action(Action),
    not agent_action(Action),
    not exogenous_action(Action),
    Action != wait,
    Reason = "Action is neither an agent action nor an exogenous action".

invalid(action(Action), Reason) :-
    action(Action),
    not physical_action(Action),
    not mental_action(Action),
    Action != wait,
    Reason = "Action is neither a physical action nor a mental action".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Authorization (no timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(permitted(Action), Reason) :-
    permitted(Action),
    not action(Action),
    Reason = "Action is not defined in action/1".

-invalid(permitted(Action), Reason) :-
    -permitted(Action),
    not action(Action),
    Reason = "Action is not defined in action/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Authorization (with timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(permitted(Action, Timestep), Reason) :-
    permitted(Action, Timestep),
    not action(Action),
    Reason = "Action is not defined in action/1".

-invalid(permitted(Action, Timestep), Reason) :-
    -permitted(Action, Timestep),
    not action(Action),
    Reason = "Action is not defined in action/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Obligation (no timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(obl(Action), Reason) :-
    obl(Action),
    not action(Action),
    not action(neg(Action)),
    Reason = "Action is not defined in action/1".

-invalid(obl(Action), Reason) :-
    -obl(Action),
    not action(Action),
    not action(neg(Action)),
    Reason = "Action is not defined in action/1".

invalid(obl(neg(neg(Action))), Reason) :-
    obl(neg(neg(Action))),
    Reason = "Double neg() in obl".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Obligation (with timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(obl(Action, Timestep), Reason) :-
    obl(Action, Timestep),
    not action(Action),
    not action(neg(Action)),
    Reason = "Action is not defined in action/1".

-invalid(obl(Action, Timestep), Reason) :-
    -obl(Action, Timestep),
    not action(Action),
    not action(neg(Action)),
    Reason = "Action is not defined in action/1".

invalid(obl(neg(neg(Action)), Timestep), Reason) :-
    obl(neg(neg(Action)), Timestep),
    Reason = "Double neg() in obl".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Compliance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(auth_compliance(Level), Reason) :-
    -auth_compliance(Level),
    Level != strong,
    Level != weak,
    Reason = "Invalid authorization compliance level".
