#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Non compliant if at least one of auth_compliant or obl_compliant is false
:-
    1 { -auth_compliant ; -obl_compliant }.
