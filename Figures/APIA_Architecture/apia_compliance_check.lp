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

:~
    interpretation(_, current_timestep),
    occurs(Action, Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    not permitted(Action, Timestep).  % We are weakly compliant
    [1@2, prefer_strong, occurs(Action, Timestep)]

#maximize{ Timestep, prefer_strong_now, Action :
    interpretation(_, current_timestep),
    occurs(Action, Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    not permitted(Action, Timestep)  % We are weakly compliant
}.

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
% Maximizes authorization compliance

:~
    interpretation(_, current_timestep),
    occurs(Action, Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    -permitted(Action, Timestep).  % We are non-compliant
    [1@1, prefer_weak, occurs(Action, Timestep)]

#maximize{ Timestep, prefer_weak_now, Action :
    interpretation(_, current_timestep),
    occurs(Action, Timestep),
    Timestep >= current_timestep,
    agent_action(Action),
    -permitted(Action, Timestep)  % We are non-compliant
}.

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

:~
    interpretation(_, current_timestep),
    obl(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    not occurs(Action, Timestep).
    [1@1, do_action, obl(Action, Timestep)]

#maximize{ Timestep, do_action_now, Action :
    interpretation(_, current_timestep),
    obl(Action, Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    not occurs(Action, Timestep)
}.

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

:~
    interpretation(_, current_timestep),
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    occurs(Action, Timestep).
    [1@2, refrain_from_action, obl(Action, Timestep)]

#maximize{ Timestep, refrain_from_action_now, Action :
    interpretation(_, current_timestep),
    obl(neg(Action), Timestep),
    agent_action(Action),
    Timestep >= current_timestep,
    occurs(Action, Timestep)
}.

#program apia_options_obl_refrain_from_action_3(current_timestep).
% Option 3
% (do nothing)
