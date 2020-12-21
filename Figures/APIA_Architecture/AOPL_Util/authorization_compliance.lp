% Iff [for all occurs(Action, TimeStep), permitted(Action, TimeStep) is true],
%   then we are strongly compliant
%
% Inverse: Iff [there exists occurs(Action, TimeStep), permitted(Action, TimeStep) is not true],
%   then we are not strongly compliant
-auth_compliance(strong) :-
    occurs(Action, TimeStep),
    not permitted(Action, TimeStep).

% Iff [for all occurs(Action, TimeStep), permitted(Action, TimeStep) is not false],
%   then we are weakly compliant
%
% Inverse: Iff [there exists occurs(Action, TimeStep), permitted(Action, TimeStep) is false],
%   then we are not weakly compliant
-auth_compliance(weak) :-
    occurs(Action, TimeStep),
    -permitted(Action, TimeStep).
