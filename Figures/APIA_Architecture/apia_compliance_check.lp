%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

#program apia_options_auth_weakly_compliant_1.
% Option 1

:-
    not -auth_compliance(weak),  % We are weakly compliant
    -auth_compliance(strong).

#program apia_options_auth_weakly_compliant_2.
% Option 2

:-
    not -auth_compliance(weak),  % We are weakly compliant
    occurs(Action, Timestep),
    agent_action(Action),
    not permitted(Action, Timestep),  % We are not strongly compliant
    not abnormal(require_permitted(Action, Timestep)).

{ apply_cr_rule(abnormal(require_permitted(Action, Timestep))) } :-
    occurs(Action, Timestep),
    agent_action(Action),
    not permitted(Action, Timestep).

abnormal(require_permitted(Action, Timestep)) :-
    apply_cr_rule(abnormal(require_permitted(Action, Timestep))).

#program apia_options_auth_weakly_compliant_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% If our activity is non-compliant,
% either:
%   - consider the activity futile (requires compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers weak compliance)
%   - continue the activity (ignores policy completely)

#program apia_options_auth_non_compliant_1.
% Option 1

:-
    -auth_compliance(weak).

#program apia_options_auth_non_compliant_2.
% Option 2

:-
    occurs(Action, Timestep),
    agent_action(Action),
    -permitted(Action, Timestep),  % We are non-compliant
    not abnormal(require_auth_compliance(Action, Timestep)).

{ apply_cr_rule(abnormal(require_auth_compliance(Action, Timestep))) } :-
    occurs(Action, Timestep),
    agent_action(Action),
    -permitted(Action, Timestep).

abnormal(require_auth_compliance(Action, Timestep)) :-
    apply_cr_rule(abnormal(require_auth_compliance(Action, Timestep))).

#program apia_options_auth_non_compliant_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% Either:
%   - Maximize compliance with an authorization policy
%   - Minimize activity length (within compliance threshold). See above options

% Option 1
#program apia_options_auth_optimization_1(minimize_priority).

:~
    -auth_compliance(strong).
    [1@minimize_priority, -auth_compliance(weak)]

:~
    -auth_compliance(weak).
    [2@minimize_priority, -auth_compliance(weak)]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Obligation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If an activity fails to do a required action while achieving a goal
% then we either:
%   - Consider the activity futile
%   - Consider the activity futile, unless the goal cannnot be achieved by doing the action
%   - Ignore the policy

#program apia_options_obl_do_action_1.
% Option 1

:-
    agent_action(Action),
    obl(Action, Timestep),
    not occurs(Action, Timestep).

#program apia_options_obl_do_action_2.
% Option 2

:-
    agent_action(Action),
    obl(Action, Timestep),
    not occurs(Action, Timestep),
    not abnormal(satisfy_obl(Action, Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))) } :-
    obl(Action, Timestep),
    agent_action(Action).

abnormal(satisfy_obl(Action, Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))),
    agent_action(Action).

#program apia_options_obl_do_action_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% If an activity fails to refrain a forbidden action while achieving a goal
% then we either:
%   - Consider the activity futile
%   - Consider the activity futile, unless the goal can only be achieved by doing the action
%   - Ignore the policy

#program apia_options_obl_refrain_from_action_1.
% Option 1

:-
    obl(neg(Action), Timestep),
    agent_action(Action),
    occurs(Action, Timestep).

#program apia_options_obl_refrain_from_action_2.
% Option 2

:-
    obl(neg(Action), Timestep),
    agent_action(Action),
    occurs(Action, Timestep),
    not abnormal(satisfy_obl(neg(Action), Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))) } :-
    obl(neg(Action), Timestep),
    agent_action(Action).

abnormal(satisfy_obl(neg(Action), Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))),
    agent_action(Action).

#program apia_options_obl_refrain_from_action_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

#program apia_options_obl_optimization(minimize_priority).

% Minimize violations with an obligation policy
:~
    -obl_compliant(Timestep).
    [1@minimize_priority, obl_compliant(Timestep)]
