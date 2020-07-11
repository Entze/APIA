#include "authorization_compliance.lp".
#include "obligation_compliance.lp".

% Non compliant if either auth_compliant or obl_compliant is false
:-
    { -auth_compliant ; -obl_compliant }.
