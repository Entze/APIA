%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

goal(policy_compliant(Goal)) :-
    goal(Goal),
    @function_signature(Goal) != "policy_compliant/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% require_auth_compliance(ComplianceLevel)
%   Compliance = (strong; weak)

% require_obl_compliance(Type)
%   Type (do_action; refrain_from_action)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(Type, Fluent) :-
    policy_fluent(Type, Fluent).

policy_fluent(defined_negative, policy_compliant(Fluent)) :-
    physical_fluent(_, Fluent).

policy_fluent(inertial, auth_compliance(ComplianceLevel)) :-
    ComplianceLevel = (strong; weak).

policy_fluent(inertial, obl_compliant(Type)) :-
    Type = (do_action; refrain_from_action).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

policy_action(PolicyAction) :-
    agent_action(Action),
    physical_action(Action),
    PolicyAction = (
        ignore_not_permitted(Action);
        ignore_neg_permitted(Action);
        ignore_obl(Action);
        ignore_obl(neg(Action))
    ).

agent_action(Action) :-
    policy_action(Action).

% policy_action(Action) is neither a physical action nor a mental action

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program apia_action_description(current_timestep).

% (Valid AL)
%
% -policy_compliant(Fluent) if
%   -Fluent
-holds(policy_compliant(Fluent), Timestep) :-
    physical_fluent(_, Fluent),
    -holds(Fluent, Timestep).

% -policy_compliant(Fluent) if
%   Timestep > current_timestep,
%   require_auth_compliance(ComplianceLevel)
%   -auth_compliance(ComplianceLevel)
-holds(policy_compliant(Fluent), Timestep) :-
    Timestep > current_timestep,
    physical_fluent(_, Fluent),
    require_auth_compliance(ComplianceLevel),
    -holds(auth_compliance(ComplianceLevel), Timestep).

% -policy_compliant(Fluent) if
%   Timestep > current_timestep,
%   require_obl_compliance(Type)
%   -obl_compliant(Type)
-holds(policy_compliant(Fluent), Timestep) :-
    Timestep > current_timestep,
    physical_fluent(_, Fluent),
    require_obl_compliance(Type),
    -holds(obl_compliant(Type), Timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (Action, not ignore_not_permitted(Action))
%   causes -auth_compliance(strong)
%   if
%     Timestep >= current_timestep,
%     agent_action(Action)
%     not policy_action(Action)
%     not permitted(Action)
-holds(auth_compliance(strong), Timestep + 1) :-
    Timestep >= current_timestep,
    agent_action(Action),
    not policy_action(Action),
    occurs(Action, Timestep),
    not occurs(ignore_not_permitted(Action), Timestep),
    not permitted(Action, Timestep).

% impossible ignore_not_permitted(Action) if
%   permitted(Action)
impossible(ignore_not_permitted(Action), Timestep) :-
    Timestep >= current_timestep,
    agent_action(Action),
    permitted(Action, Timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (Action, not ignore_neg_permitted(Action))
%   causes -auth_compliance(weak)
%   if
%     Timestep >= current_timestep,
%     agent_action(Action)
%     not policy_action(Action)
%     -permitted(Action)
-holds(auth_compliance(weak), Timestep + 1) :-
    Timestep >= current_timestep,
    agent_action(Action),
    not policy_action(Action),
    occurs(Action, Timestep),
    not occurs(ignore_neg_permitted(Action), Timestep),
    -permitted(Action, Timestep).

% impossible ignore_neg_permitted(Action) if
%   not -permitted(Action)
impossible(ignore_neg_permitted(Action), Timestep) :-
    step(Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    not -permitted(Action, Timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (not Action, not ignore_obl(Action))
%   causes -obl_compliant(do_action)
%   if
%     Timestep >= current_timestep,
%     agent_action(Action)
%     not policy_action(Action)
%     obl(Action)
-holds(obl_compliant(do_action), Timestep + 1) :-
    Timestep >= current_timestep,
    agent_action(Action),
    not policy_action(Action),
    obl(Action, Timestep),
    not occurs(Action, Timestep),
    not ignore_obl(Action, Timestep).

% impossible ignore_obl(Action) if
%   not obl(Action)
impossible(ignore_obl(Action), Timestep) :-
    step(Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    physical_action(Action),
    not obl(Action, Timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (Action, not ignore_obl(neg(Action)))
%   causes -obl_compliant(refrain_from_action)
%   if
%     Timestep >= current_timestep,
%     agent_action(Action)
%     not policy_action(Action)
%     obl(neg(Action))
-holds(obl_compliant(refrain_from_action), Timestep + 1) :-
    Timestep >= current_timestep,
    agent_action(Action),
    not policy_action(Action),
    obl(neg(Action), Timestep),
    occurs(Action, Timestep),
    not ignore_obl(neg(Action), Timestep).

% impossible ignore_obl(neg(Action)) if
%   not obl(neg(Action))
impossible(ignore_obl(Action), Timestep) :-
    step(Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    physical_action(Action),
    not obl(neg(Action), Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation
#program apia_axioms(current_timestep).

observed(policy_compliant(Fluent), Timestep) :-
    observed(Fluent, Timestep),
    physical_fluent(_, Fluent).

-observed(policy_compliant(Fluent), Timestep) :-
    -observed(Fluent, Timestep),
    physical_fluent(_, Fluent).

% Given a non-compliant past, we want to be able to plan for a compliant future
% Hence, we treat past events as being compliant.

holds(auth_compliance(ComplianceLevel), Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    policy_fluent(inertial, auth_compliance(ComplianceLevel)).

holds(obl_compliant(Type), Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    policy_fluent(inertial, obl_compliant(Type)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

#program apia_options_auth_weakly_compliant_1(current_timestep).
% Option 1

require_auth_compliance(ComplianceLevel) :-
    ComplianceLevel = strong.

% (Valid AL)
%
% impossible ignore_not_permitted(Action)
impossible(ignore_not_permitted(Action), Timestep) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(Action),
    physical_action(Action).

#program apia_options_auth_weakly_compliant_2(current_timestep).
% Option 2

require_auth_compliance(ComplianceLevel) :-
    ComplianceLevel = strong.

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_not_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_not_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

#program apia_options_auth_weakly_compliant_3(current_timestep).
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% If our activity is non-compliant,
% either:
%   - consider the activity futile (requires compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers weak compliance)
%   - continue the activity (ignores policy completely)

#program apia_options_auth_non_compliant_1(current_timestep).
% Option 1

require_auth_compliance(ComplianceLevel) :-
    ComplianceLevel = weak.

% (Valid AL)
%
% impossible ignore_neg_permitted(Action)
impossible(ignore_neg_permitted(Action), Timestep) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(Action),
    physical_action(Action).

#program apia_options_auth_non_compliant_2(current_timestep).
% Option 2
% Implicitly maximizes authorization compliance

require_auth_compliance(ComplianceLevel) :-
    ComplianceLevel = weak.

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_neg_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_neg_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

#program apia_options_auth_non_compliant_3(current_timestep).
% Option 3
% (do nothing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Obligation settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If an activity fails to do a required action while achieving a goal
% then we either:
%   - Consider the activity futile
%   - Consider the activity futile, unless the goal cannnot be achieved by doing the action
%   - Ignore the policy

#program apia_options_obl_do_action_1(current_timestep).
% Option 1

require_obl_compliance(Type) :-
    Type = do_action.

% (Valid AL)
%
% impossible ignore_obl(Action)
impossible(ignore_obl(Action), Timestep) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(Action),
    physical_action(Action).

#program apia_options_obl_do_action_2(current_timestep).
% Option 2
% Implicitly maximizes obl compliance

require_obl_compliance(Type) :-
    Type = do_action.

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


#program apia_options_obl_do_action_3(current_timestep).
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% If an activity fails to refrain a forbidden action while achieving a goal
% then we either:
%   - Consider the activity futile
%   - Consider the activity futile, unless the goal can only be achieved by doing the action
%   - Ignore the policy

#program apia_options_obl_refrain_from_action_1(current_timestep).
% Option 1

require_obl_compliance(Type) :-
    Type = refrain_from_action.

% (Valid AL)
%
% impossible ignore_obl(neg(Action))
impossible(ignore_obl(neg(Action)), Timestep) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(Action),
    physical_action(Action).

#program apia_options_obl_refrain_from_action_2(current_timestep).
% Option 2
% Implicitly maximizes obl compliance

require_obl_compliance(Type) :-
    Type = refrain_from_action.

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(neg(Action)),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
:~
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(neg(Action)),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


#program apia_options_obl_refrain_from_action_3(current_timestep).
% Option 3
% (do nothing)

% ---------------------------------------------------------------------

#program apia_options_misc_2(current_timestep).

% prefer(plan_existing(PolicyAction, NewerTimestep), plan_existing(PolicyAction, OlderTimestep)).
:~
    policy_action(PolicyAction),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    HigherPriorityCRRule = plan_existing(PolicyAction, NewerTimestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, OlderTimestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]


% prefer(plan_new(PolicyAction, NewerTimestep), plan_new(PolicyAction, OlderTimestep)).
:~
    policy_action(PolicyAction),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    HigherPriorityCRRule = plan_new(PolicyAction, NewerTimestep),
    LowerPriorityCRRule = plan_new(PolicyAction, OlderTimestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]
