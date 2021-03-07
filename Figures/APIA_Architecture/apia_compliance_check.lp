%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Authorization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If our activity is weakly compliant,
% either:
%   - consider the activity futile (paranoid; requires strong compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers strong policy compliance)
%   - continue the activity (prefers prior commitments over strong compliance)

% If our activity is non-compliant,
% either:
%   - consider the activity futile (paranoid; requires compliance)
%   - consider the activity futile unless it is the most compliant activity (prefers compliance)
%   - continue the activity (pure utilitarian; ignores policy completely)

% Either:
%   - Maximize compliance with an authorization policy
%   - Minimize activity length (within compliance threshold)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Obligation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Always try to satisfy an obligation policy to do an action.
% If we are unable to satisfy an obligation policy to do an action, then we ignore it.
% We cannot be at fault for not doing what we cannot do.

:-
    action(Action),
    obl(Action, Timestep),
    not occurs(Action, Timestep),
    not abnormal(satisfy_obl(Action, Timestep)).

{ apply_cr_rule(satisfy_obl(Action, Timestep)) } :-
    obl(Action, Timestep).

abnormal(satisfy_obl(Action, Timestep)) :-
    apply_cr_rule(satisfy_obl(Action, Timestep)).

% ------------------------------------------------------------------------------

% If we are unable to satisfy an obligation policy to abstain from an action while achieving the goal
% then we either:
%   - Consider the goal futile
%   - Ignore the policy

% Option 1
:-
    -obl_compliant.

% Option 2
% (do nothing)

% ------------------------------------------------------------------------------

% Minimize violations with an obligation policy
