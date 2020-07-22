#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Non-compliant if auth_compliant is false
:-
    -auth_compliant.

% Non-compliant if obl_compliant is false
:-
    -obl_compliant.
