%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

goal(policy_compliant(Goal)) :-
    goal(Goal),
    @function_signature(Goal) != "policy_compliant/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(defined_negative, policy_compliant(Fluent)) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% -policy_compliant(Fluent) if
%   -Fluent
-holds(policy_compliant(Fluent), timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    -holds(Fluent, timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Misc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

observed(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    observed(Fluent, Timestep).

-observed(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    -observed(Fluent, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

#program apia_options_auth_weakly_compliant_1(current_timestep).
% Option 1

% -policy_compliant(Fluent) if
%   not -auth_compliance(future, weak),  % We are weakly compliant
%   -auth_compliance(future, strong),
-holds(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    step(Timestep),
    Timestep > current_timestep,
    not -auth_compliance(future, weak),  % We are weakly compliant
    -auth_compliance(future, strong).

#program apia_options_auth_weakly_compliant_2(current_timestep).
% Option 2

:-
    not -auth_compliance(future, weak),  % We are weakly compliant
    occurs(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    not permitted(Action, Timestep),  % We are not strongly compliant
    not abnormal(require_permitted(Action, Timestep)).

{ apply_cr_rule(abnormal(require_permitted(Action, Timestep))) } :-
    occurs(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    not permitted(Action, Timestep).

abnormal(require_permitted(Action, Timestep)) :-
    apply_cr_rule(abnormal(require_permitted(Action, Timestep))).

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

% -policy_compliant(Fluent) if
%   -auth_compliance(future, weak)
-holds(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    step(Timestep),
    Timestep > current_timestep,
    -auth_compliance(future, weak).  % We are non-complaint

#program apia_options_auth_non_compliant_2(current_timestep).
% Option 2
% Implicitly maximizes authorization compliance

:-
    occurs(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    -permitted(Action, Timestep),  % We are non-compliant
    not abnormal(require_auth_compliance(Action, Timestep)).

{ apply_cr_rule(abnormal(require_auth_compliance(Action, Timestep))) } :-
    occurs(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    -permitted(Action, Timestep).

abnormal(require_auth_compliance(Action, Timestep)) :-
    apply_cr_rule(abnormal(require_auth_compliance(Action, Timestep))).

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

% -policy_compliant(Fluent) if
%   -obl_compliant(future, do_action).
-holds(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    step(Timestep),
    Timestep > current_timestep,
    -obl_compliant(future, do_action).

#program apia_options_obl_do_action_2(current_timestep).
% Option 2
% Implicitly maximizes obl compliance

:-
    agent_action(Action),
    obl(Action, Timestep),
    Timestep >= current_timestep,
    not occurs(Action, Timestep),
    not abnormal(satisfy_obl(Action, Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))) } :-
    obl(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    occurs(Action, Timestep).

abnormal(satisfy_obl(Action, Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))),
    agent_action(Action).

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

% -policy_compliant(Fluent) if
%   -obl_compliant(future, refrain_from_action).
-holds(policy_compliant(Fluent), Timestep) :-
    fluent(_, Fluent),
    @function_signature(Fluent) != "policy_compliant/1",
    step(Timestep),
    Timestep > current_timestep,
    -obl_compliant(future, refrain_from_action).

#program apia_options_obl_refrain_from_action_2(current_timestep).
% Option 2
% Implicitly maximizes obl compliance

:-
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    occurs(Action, Timestep),
    not abnormal(satisfy_obl(neg(Action), Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))) } :-
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    occurs(Action, Timestep).

abnormal(satisfy_obl(neg(Action), Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))),
    agent_action(Action).

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
