%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% General %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(fluent(FluentType, Fluent), Reason) :-
    fluent(FluentType, Fluent),
    FluentType != defined,
    FluentType != defined_negative,
    FluentType != inertial,
    Reason = @str_format("Invalid FluentType: {}", FluentType).

invalid(holds(Fluent, Timestep), Reason) :-
    holds(Fluent, Timestep),
    not fluent(_, Fluent),
    Reason = @str_format("Fluent ({}) is not defined in fluent/2", Fluent).

invalid(occurs(Action, Timestep), Reason) :-
    occurs(Action, Timestep),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(fluent(inertial, Fluent), Reason) :-
    physical_fluent(inertial, Fluent),
    Timestep = 0,
    not observed(Fluent, Timestep),
    not -observed(Fluent, Timestep),
    Reason = "Warning: No initial observation of fluent".

invalid(holds(Fluent), Reason) :-
    holds(Fluent),
    Reason = "Missing timestep in holds(Fluent, Timestep)".

invalid(holds(Fluent), Reason) :-
    -holds(Fluent),
    Reason = "Missing timestep in -holds(Fluent, Timestep)".

invalid(occurs(Action), Reason) :-
    occurs(Action),
    Reason = "Missing timestep in occurs(Action, Timestep)".

invalid(occurs(Action), Reason) :-
    -occurs(Action),
    Reason = "Missing timestep in -occurs(Action, Timestep)".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AIA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(action(Action), Reason) :-
    action(Action),
    not agent_action(Action),
    not exogenous_action(Action),
    Action != wait,
    Reason = @str_format("Action ({}) is neither an agent action nor an exogenous action", Action).

invalid(action(Action), Reason) :-
    action(Action),
    not physical_action(Action),
    not mental_action(Action),
    not policy_action(Action),
    Action != wait,
    Reason = @str_format("Action ({}) is not a physical action, a mental action, or a policy action", Action).

invalid(action(Action), Reason) :-
    action(Action),
    physical_action(Action),
    mental_action(Action),
    Reason = @str_format("Action ({}) is both a physical action and a mental action. You should not define mental actions", Action).

% Note: Our assumption
invalid(action(Action), Reason) :-
    action(Action),
    agent_action(Action),
    exogenous_action(Action),
    Reason = @str_format("Action ({}) is both an agent action and an exogenous action", Action).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Authorization (no timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(permitted(Action), Reason) :-
    permitted(Action),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

-invalid(permitted(Action), Reason) :-
    -permitted(Action),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Authorization (with timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(permitted(Action), Reason) :-
    permitted(Action),
    Reason = "Missing timestep in permitted(Action, Timestep)".

invalid(permitted(Action), Reason) :-
    -permitted(Action),
    Reason = "Missing timestep in permitted(Action, Timestep)".

invalid(permitted(Action, Timestep), Reason) :-
    permitted(Action, Timestep),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

-invalid(permitted(Action, Timestep), Reason) :-
    -permitted(Action, Timestep),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(permitted(Action, Timestep), Reason) :-
    permitted(Action, Timestep),
    action(Action),
    not agent_action(Action),
    Action != wait,
    Reason = @str_format("permitted({}) can only describe agent actions", Action).

-invalid(permitted(Action, Timestep), Reason) :-
    -permitted(Action, Timestep),
    action(Action),
    not agent_action(Action),
    Action != wait,
    Reason = @str_format("-permitted({}) can only describe agent actions", Action).

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
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(obl(Action), Reason) :-
    obl(neg(Action)),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(neg(obl(Action)), Reason) :-
    -obl(Action),
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(neg(obl(Action)), Reason) :-
    -obl(neg(Action)),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(obl(neg(neg(Action))), Reason) :-
    obl(neg(neg(Action))),
    Reason = @str_format("Double neg() in obl").

invalid(neg(obl(neg(neg(Action)))), Reason) :-
    -obl(neg(neg(Action))),
    Reason = @str_format("Double neg() in -obl").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Obligation (with timesteps) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(obl(Action), Reason) :-
    obl(Action),
    Reason = "Missing timestep in obl(Action, Timestep)".

invalid(obl(Action), Reason) :-
    -obl(Action),
    Reason = "Missing timestep in obl(Action, Timestep)".

invalid(obl(Action, Timestep), Reason) :-
    obl(Action, Timestep),
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(obl(Action, Timestep), Reason) :-
    obl(neg(Action), Timestep),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(Action, Timestep),
    @function_signature(Action) != "neg/1",
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(neg(Action), Timestep),
    not action(Action),
    Reason = @str_format("Action ({}) is not defined in action/1", Action).

% ------------------------------------------------------------------------------------------

invalid(obl(Action, Timestep), Reason) :-
    obl(Action, Timestep),
    @function_signature(Action) != "neg/1",
    action(Action),
    not agent_action(Action),
    Reason = @str_format("Action ({}) is not an agent action", Action).

invalid(obl(Action, Timestep), Reason) :-
    obl(neg(Action), Timestep),
    action(Action),
    not agent_action(Action),
    Reason = @str_format("Action ({}) is not an agent action", Action).

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(Action, Timestep),
    @function_signature(Action) != "neg/1",
    action(Action),
    not agent_action(Action),
    Reason = @str_format("Action ({}) is not an agent action", Action).

invalid(neg(obl(Action, Timestep)), Reason) :-
    -obl(neg(Action), Timestep),
    action(Action),
    not agent_action(Action),
    Reason = @str_format("Action ({}) is not an agent action", Action).

% ------------------------------------------------------------------------------------------

invalid(obl(neg(neg(Action)), Timestep), Reason) :-
    obl(neg(neg(Action)), Timestep),
    Reason = "Double neg() in obl".

invalid(neg(obl(neg(neg(Action)), Timestep)), Reason) :-
    -obl(neg(neg(Action)), Timestep),
    Reason = "Double neg() in -obl".

% ------------------------------------------------------------------------------------------

invalid(obl(Action, Timestep), Reason) :-
    action(Action),
    obl(Action, Timestep),
    obl(neg(Action), Timestep),
    Reason = @str_format("obl({0}) contradicts obl(-{0})", Action).

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

% ------------------------------------------------------------------------------------------

invalid(obl(Action, Timestep), Reason) :-
    action(Action),
    obl(Action, Timestep),
    impossible(Action, Timestep),
    Reason = @str_format("obl({0}) when {0} is physically impossible", Action).

% ------------------------------------------------------------------------------------------

invalid(obl(Action, Timestep), Reason) :-
    action(Action),
    obl(Action, Timestep),
    -permitted(Action, Timestep),
    Reason = @str_format("obl({0}) contradicts -permitted({0})", Action).

invalid(obl(neg(Action), Timestep), Reason) :-
    action(Action),
    obl(neg(Action), Timestep),
    permitted(Action, Timestep),
    Reason = @str_format("obl(-{0}) contradicts permitted({0})", Action).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL: Compliance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

invalid(auth_compliance(ComplianceLevel), Reason) :-
    -auth_compliance(ComplianceLevel),
    ComplianceLevel != strong,
    ComplianceLevel != weak,
    Reason = @str_format("Invalid authorization compliance level: {}", ComplianceLevel).
