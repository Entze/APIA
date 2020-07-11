#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Weakly compliant if:
%   * weakly compliant with authorization policy (i.e. not non-compliant)
%   * compliant with obligation policy
:-
    not -auth_compliant,
    obl_compliant.
