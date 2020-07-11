#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Strongly compliant if:
%   * strongly compliant with authorization policy
%   * compliant with obligation policy
:-
    auth_compliant,
    obl_compliant.
