%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(Type, Fluent) :-
    policy_fluent(Type, Fluent).

policy_fluent(inertial, auth_compliance(ComplianceLevel)) :-
    ComplianceLevel = (strong; weak).

policy_fluent(inertial, obl_compliance).

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program policy_action_description(timestep).
% Only set timestep to current or future timesteps

% (Action, not ignore_permitted(Action))
%   causes -auth_compliance(strong)
%   if
%     agent_action(Action)
%     not permitted(Action)
-holds(auth_compliance(strong), timestep + 1) :-
    agent_action(Action),
    occurs(Action, timestep),
    not occurs(ignore_permitted(Action), timestep),
    not permitted(Action, timestep).

% ----------------------------------------------

% (Action, not ignore_neg_permitted(Action))
%   causes -auth_compliance(weak)
%   if
%     agent_action(Action)
%     -permitted(Action)
-holds(auth_compliance(weak), timestep + 1) :-
    agent_action(Action),
    occurs(Action, timestep),
    not occurs(ignore_neg_permitted(Action), timestep),
    -permitted(Action, timestep).

% ----------------------------------------------

% (not Action, not ignore_obl(Action))
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     obl(Action)
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    obl(Action, timestep),
    not occurs(Action, timestep),
    not ignore_obl(Action, timestep).

% (Action, not ignore_obl(neg(Action)))
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     obl(neg(Action))
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    obl(neg(Action), timestep),
    occurs(Action, timestep),
    not ignore_obl(neg(Action), timestep).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

#program apia_options_auth_weakly_compliant_1(current_timestep).
% Option 1

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
