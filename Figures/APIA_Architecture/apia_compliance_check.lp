%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(Type, Fluent) :-
    policy_fluent(Type, Fluent).

policy_fluent(inertial, auth_compliance(ComplianceLevel)) :-
    ComplianceLevel = (strong; weak).

policy_fluent(inertial, obl_compliance).

% Strong auth compliance
%
% require_permitted(Action)
policy_fluent(defined_negative, require_permitted(Action)) :-
    agent_action(Action),
    physical_action(Action).

% Weak auth compliance
%
% require_auth_compliance(Action)
policy_fluent(defined_negative, require_auth_compliance(Action)) :-
    agent_action(Action),
    physical_action(Action).

% satisfy_obl(Happening)
policy_fluent(defined_negative, satisfy_obl(Happening)) :-
    agent_action(Action),
    physical_action(Action),
    Happening = (
        Action;
        neg(Action)
    ).

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

% Action
%   causes -auth_compliance(strong)
%   if
%     agent_action(Action)
%     not permitted(Action)
%     require_permitted(Action)
-holds(auth_compliance(strong), timestep + 1) :-
    agent_action(Action),
    occurs(Action, timestep),
    not permitted(Action, timestep).

% ignore_permitted(Action)
%   causes
%     -require_permitted(Action)
-holds(require_permitted(Action), timestep + 1) :-
    occurs(ignore_permitted(Action), timestep).

% ----------------------------------------------

% Action
%   causes -auth_compliance(weak)
%   if
%     agent_action(Action)
%     -permitted(Action)
%     require_auth_compliance(Action)
-holds(auth_compliance(weak), timestep + 1) :-
    agent_action(Action),
    occurs(Action, timestep),
    -permitted(Action, timestep).

% ignore_neg_permitted(Action)
%   causes
%     -require_auth_compliance(Action)
-holds(require_auth_compliance(Action), timestep + 1) :-
    occurs(ignore_neg_permitted(Action), timestep).

% ----------------------------------------------

% (not Action)
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     obl(Action)
%     satisfy_obl(Action, timestep)
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    obl(Action, timestep),
    not occurs(Action, timestep).

% Action
%   causes -obl_compliant
%   if
%     agent_action(Action)
%     obl(neg(Action))
%     satisfy_obl(neg(Action))
-holds(obl_compliant, timestep + 1) :-
    agent_action(Action),
    obl(neg(Action), timestep),
    occurs(Action, timestep).

% ignore_obl(Happening)
%   causes
%     -satisfy_obl(Happening, Timestep).
-holds(satisfy_obl(Happening), timestep + 1) :-
    occurs(ignore_obl(Happening), timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    agent_action(Action),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    % Condition for CR-rule 1
    occurs(Action, NewerTimestep),
    -permitted(Action, NewerTimestep),

    % Condition for CR-rule 2
    occurs(Action, OlderTimestep),
    -permitted(Action, OlderTimestep),

    HigherPriorityCRRule = abnormal(require_auth_compliance(Action, NewerTimestep)),
    LowerPriorityCRRule = abnormal(require_auth_compliance(Action, OlderTimestep)).

#program apia_options_auth_non_compliant_3(current_timestep).
% Option 3
% (do nothing)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Obligation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    agent_action(Action),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    % Condition for CR-rule 1
    obl(Action, NewerTimestep),
    occurs(Action, NewerTimestep),

    % Condition for CR-rule 2
    obl(Action, OlderTimestep),
    occurs(Action, OlderTimestep),

    HigherPriorityCRRule = abnormal(satisfy_obl(Action, NewerTimestep)),
    LowerPriorityCRRule = abnormal(satisfy_obl(Action, OlderTimestep)).

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

% prefer(abnormal(satisfy_obl(neg(Action), NewerTimestep)), abnormal(satisfy_obl(neg(Action), OlderTimestep)))
cr_prefer(HigherPriorityCRRule, LowerPriorityCRRule) :-
    agent_action(Action),
    step(NewerTimestep),
    step(OlderTimestep),
    OlderTimestep >= current_timestep,
    NewerTimestep >= current_timestep,
    NewerTimestep > OlderTimestep,

    % Condition for CR-rule 1
    obl(neg(Action), NewerTimestep),
    occurs(Action, NewerTimestep),

    % Condition for CR-rule 2
    obl(neg(Action), OlderTimestep),
    occurs(Action, OlderTimestep),

    HigherPriorityCRRule = abnormal(satisfy_obl(neg(Action), NewerTimestep)),
    LowerPriorityCRRule = abnormal(satisfy_obl(neg(Action), OlderTimestep)).

#program apia_options_obl_refrain_from_action_3(current_timestep).
% Option 3
% (do nothing)
