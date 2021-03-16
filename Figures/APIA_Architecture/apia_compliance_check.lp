%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (paranoid; requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong policy compliance)
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
    -auth_compliance(strong),
    not abnormal(require_auth_compliance(strong)).

{ apply_cr_rule(abnormal(require_auth_compliance(strong))) }.

abnormal(require_auth_compliance(strong)) :-
    apply_cr_rule(abnormal(require_auth_compliance(strong))).

#program apia_options_auth_weakly_compliant_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% If our activity is non-compliant,
% either:
%   - consider the activity futile (cautious; requires compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers compliance, but utilitarian at heart)
%   - continue the activity (pure utilitarian; ignores policy completely)

#program apia_options_auth_non_compliant_1.
% Option 1
:-
    -auth_compliance(weak).

#program apia_options_auth_non_compliant_2.
% Option 2
:-
    -auth_compliance(weak),
    not abnormal(require_auth_compliance(weak)).

{ apply_cr_rule(require_auth_compliance(weak)) }.

abnormal(require_auth_compliance(weak)) :-
    apply_cr_rule(require_auth_compliance(weak)).

#program apia_options_auth_non_compliant_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

% Either:
%   - Maximize compliance with an authorization policy (cautious)
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

#program apia_options_obl_do_action_1.
% Option:
% Always try to satisfy an obligation policy to do an action.
% If we are unable to satisfy an obligation policy to do an action, then we ignore it.
% We cannot be at fault for not doing what we cannot do.

:-
    action(Action),
    obl(Action, Timestep),
    not occurs(Action, Timestep),
    not abnormal(satisfy_obl(Action, Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))) } :-
    obl(Action, Timestep),
    action(Action).

abnormal(satisfy_obl(Action, Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(Action, Timestep))),
    action(Action).

% ------------------------------------------------------------------------------

% If we are unable to satisfy an obligation policy to abstain from an action while achieving the goal
% then we either:
%   - Consider the goal futile (cautious)
%   - Consider the goal futile, unless it is the only way of achieving the goal (utilitarian)
%   - Ignore the policy (insubordinate)

#program apia_options_obl_refrain_from_action_1.
% Option 1
:-
    obl(neg(Action), Timestep),
    action(Action),
    not -occurs(Action, Timestep).

#program apia_options_obl_refrain_from_action_2.
% Option 2
:-
    obl(neg(Action), Timestep),
    action(Action),
    not -occurs(Action, Timestep),
    not abnormal(satisfy_obl(neg(Action), Timestep)).

{ apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))) } :-
    obl(neg(Action), Timestep),
    action(Action).

abnormal(satisfy_obl(neg(Action), Timestep)) :-
    apply_cr_rule(abnormal(satisfy_obl(neg(Action), Timestep))),
    action(Action).

#program apia_options_obl_refrain_from_action_3.
% Option 3
% (do nothing)

% ------------------------------------------------------------------------------

#program apia_options_obl_optimization(minimize_priority).

% Minimize violations with an obligation policy
:~
    -obl_compliant(Timestep).
    [1@minimize_priority, obl_compliant(Timestep)]
