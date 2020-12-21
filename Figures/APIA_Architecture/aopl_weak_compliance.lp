#include "AOPL_Util/authorization_compliance.lp".
#include "AOPL_Util/obligation_compliance.lp".

% Weakly compliant if:
%   * weakly compliant with authorization policy (i.e. not non-compliant)
%   * compliant with obligation policy
%
% Closed-world assumption:
%   auth_compliance(weak) === not -auth_compliance(weak)
%   obl_compliant === not -obl_compliant
:-
    not -auth_compliance(weak),
    not -obl_compliant.
