%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

goal(policy_compliant(Goal)) :-
    goal(Goal),
    @function_signature(Goal) != "policy_compliant/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% minimum_allowed_auth_compliance(ComplianceLevel)
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
        ignore_permitted(Action);
        ignore_neg_permitted(Action);
        ignore_obl(Action);
        ignore_obl(neg(Action))
    ).

agent_action(Action) :-
    policy_action(Action).

% policy_action(Action) is neither a physical action nor a mental action

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program apia_action_description(current_timestep).
% Only set timestep to current or future timesteps

% (Valid AL)
%
% -policy_compliant(Fluent) if
%   -Fluent
-holds(policy_compliant(Fluent), timestep) :-
    physical_fluent(_, Fluent),
    -holds(Fluent, timestep).

% -policy_compliant(Fluent) if
%   minimum_allowed_auth_compliance(ComplianceLevel)
%   -auth_compliance(ComplianceLevel)
-holds(policy_compliant(Fluent), timestep) :-
    physical_fluent(_, Fluent),
    minimum_allowed_auth_compliance(ComplianceLevel),
    -holds(auth_compliance(ComplianceLevel), timestep).

% -policy_compliant(Fluent) if
%   require_obl_compliance(Type)
%   -obl_compliant(Type)
-holds(policy_compliant(Fluent), timestep) :-
    physical_fluent(_, Fluent),
    require_obl_compliance(Type),
    -holds(obl_compliant(Type), timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (Action, not ignore_permitted(Action))
%   causes -auth_compliance(strong)
%   if
%     agent_action(Action)
%     not policy_action(Action)
%     not permitted(Action)
-holds(auth_compliance(strong), timestep + 1) :-
    agent_action(Action),
    not policy_action(Action),
    occurs(Action, timestep),
    not occurs(ignore_permitted(Action), timestep),
    not permitted(Action, timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (Action, not ignore_neg_permitted(Action))
%   causes -auth_compliance(weak)
%   if
%     agent_action(Action)
%     not policy_action(Action)
%     -permitted(Action)
-holds(auth_compliance(weak), timestep + 1) :-
    agent_action(Action),
    not policy_action(Action),
    occurs(Action, timestep),
    not occurs(ignore_neg_permitted(Action), timestep),
    -permitted(Action, timestep).

% ----------------------------------------------

% (AL-like rule)
%
% (not Action, not ignore_obl(Action))
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     not policy_action(Action)
%     obl(Action)
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    not policy_action(Action),
    obl(Action, timestep),
    not occurs(Action, timestep),
    not ignore_obl(Action, timestep).

% (AL-like rule)
%
% (Action, not ignore_obl(neg(Action)))
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     not policy_action(Action)
%     obl(neg(Action))
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    not policy_action(Action),
    obl(neg(Action), timestep),
    occurs(Action, timestep),
    not ignore_obl(neg(Action), timestep).

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
    Type = (do_action; refrain_from_action),
    policy_fluent(inertial, obl_compliant).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

#program apia_options_auth_weakly_compliant_1(current_timestep).
% Option 1

minimum_allowed_auth_compliance(ComplianceLevel) :-
    ComplianceLevel = strong.

% (Valid AL)
%
% impossible ignore_permitted(Action)
impossible(ignore_permitted(Action), Timestep) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(Action),
    physical_action(Action).

#program apia_options_auth_weakly_compliant_2(current_timestep).
% Option 2

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

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

minimum_allowed_auth_compliance(ComplianceLevel) :-
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

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_neg_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_neg_permitted(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

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

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(Action),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

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

% prefer(plan_existing(AgentAction, Timestep), plan_existing(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(neg(Action)),
    agent_action(Action),
    HigherPriorityCRRule = plan_existing(AgentAction, Timestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

% prefer(plan_new(AgentAction, Timestep), plan_new(PolicyAction, Timestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    step(Timestep),
    current_timestep <= Timestep,
    agent_action(AgentAction),
    not policy_action(AgentAction),
    policy_action(PolicyAction),
    PolicyAction = ignore_obl(neg(Action)),
    agent_action(Action),
    HigherPriorityCRRule = plan_new(AgentAction, Timestep),
    LowerPriorityCRRule = plan_new(PolicyAction, Timestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

#program apia_options_obl_refrain_from_action_3(current_timestep).
% Option 3
% (do nothing)

% ---------------------------------------------------------------------

#program apia_options_misc_2(current_timestep).

% prefer(plan_existing(PolicyAction, NewerTimestep), plan_existing(PolicyAction, OlderTimestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    policy_action(PolicyAction),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    HigherPriorityCRRule = plan_existing(PolicyAction, NewerTimestep),
    LowerPriorityCRRule = plan_existing(PolicyAction, OlderTimestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).

% prefer(plan_new(PolicyAction, NewerTimestep), plan_new(PolicyAction, OlderTimestep)).
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    policy_action(PolicyAction),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    HigherPriorityCRRule = plan_new(PolicyAction, NewerTimestep),
    LowerPriorityCRRule = plan_new(PolicyAction, OlderTimestep),
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
