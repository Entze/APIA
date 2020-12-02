#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Non-compliant if we are not even weakly compliant
:-
    -auth_compliance(weak).

% Non-compliant if obl_compliant is false
:-
    -obl_compliant.
