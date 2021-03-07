% Ensure both of these values are higher than all other priority values used in the ASP program
% and cr_rule_priority < cr_prefer_priority.
#const cr_rule_priority = 1.
#const cr_prefer_priority = 2.

% Universal CR-rule weak constraint
:~
    apply_cr_rule(CRRule).
    [1@cr_rule_priority, CRRule]
