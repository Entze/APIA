% Iff [for all occurs(Action, Timestep), permitted(Action, Timestep) is true],
%   then we are strongly compliant
%
% Inverse: Iff [there exists occurs(Action, Timestep), permitted(Action, Timestep) is not true],
%   then we are not strongly compliant
-auth_compliance(strong) :-
    occurs(Action, Timestep),
    not permitted(Action, Timestep).

% Iff [for all occurs(Action, Timestep), permitted(Action, Timestep) is not false],
%   then we are weakly compliant
%
% Inverse: Iff [there exists occurs(Action, Timestep), permitted(Action, Timestep) is false],
%   then we are not weakly compliant
-auth_compliance(weak) :-
    occurs(Action, Timestep),
    -permitted(Action, Timestep).
