#script(python)

import clingo


def str_format(template_str: clingo.Symbol, *arguments: clingo.Symbol) -> str:
    template_str = template_str.string
    arguments = (symbol.string if symbol.type == clingo.SymbolType.String else symbol
                 for symbol in arguments)
    return template_str.format(*arguments)


def function_signature(symbol: clingo.Symbol) -> str:
    return f'{symbol.name}/{len(symbol.arguments)}'

#end.

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

% ------------------------------------------------------------------------------------------

-auth_compliance(strong, Action, Timestep) :-
    occurs(Action, Timestep),
    agent_action(Action),
    not permitted(Action, Timestep).

-auth_compliance(weak, Action, Timestep) :-
    occurs(Action, Timestep),
    agent_action(Action),
    -permitted(Action, Timestep).

auth_compliance(ComplianceLevel, Action, Timestep) :-
    ComplianceLevel = (strong; weak),
    occurs(Action, Timestep),
    agent_action(Action),
    not -auth_compliance(ComplianceLevel, Action, Timestep).

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
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = "Action is not defined in action/1".

invalid(obl(Action, Timestep), Reason) :-
    obl(neg(Action), Timestep),
    not action(Action),
    Reason = "Action is not defined in action/1".

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(Action, Timestep),
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = "Action is not defined in action/1".

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(neg(Action), Timestep),
    not action(Action),
    Reason = "Action is not defined in action/1".

invalid(obl(neg(neg(Action)), Timestep), Reason) :-
    obl(neg(neg(Action)), Timestep),
    Reason = "Double neg() in obl".

invalid(neg(obl(neg(neg(Action)), Timestep)), Reason) :-
    -obl(neg(neg(Action)), Timestep),
    Reason = "Double neg() in -obl".

% ------------------------------------------------------------------------------------------

-obl_compliant(Action, Timestep) :-
    obl(Action, Timestep),
    agent_action(Action),
    not occurs(Action, Timestep).

-obl_compliant(neg(Action), Timestep) :-
    obl(neg(Action), Timestep),
    agent_action(Action),
    not -occurs(Action, Timestep).

obl_compliant(Happening, Timestep) :-
    obl(Happening, Timestep),
    not -obl_compliant(Happening, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Compliance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(auth_compliance(ComplianceLevel), Reason) :-
    -auth_compliance(ComplianceLevel),
    ComplianceLevel != strong,
    ComplianceLevel != weak,
    Reason = "Invalid authorization compliance level".
