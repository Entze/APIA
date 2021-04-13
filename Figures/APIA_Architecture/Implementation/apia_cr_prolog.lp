% Ensure both of these values are higher than all other priority values used in the ASP program
% and cr_rule_priority < cr_prefer_priority.
%
% Currently, clingo 5.4.0 uses a signed 32-integer to represent numbers.
% Thus, (2 ** 32) / 2 - 1 == 2147483647 should be the highest number supported by the grounder.
% This number is unlikely to be used elsewhere in the program.
#const cr_rule_priority = 2147483646.
#const cr_prefer_priority = 2147483647.

% Universal CR-rule weak constraint
:~
    apply_cr_rule(CRRule).
    [1@cr_rule_priority, apply_cr_rule(CRRule)]
