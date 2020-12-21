#include "AOPL_Util/authorization_compliance.lp".
#include "AOPL_Util/obligation_compliance.lp".

% Strongly compliant if:
%   * strongly compliant with authorization policy
%   * compliant with obligation policy
%
% Closed-world assumption:
%   auth_compliance(strong) === not -auth_compliance(strong)
%   obl_compliant === not -obl_compliant
:-
    not -auth_compliance(strong),
    not -obl_compliant.
