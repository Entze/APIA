% Ensure all of these values are higher than all other priority values used in the ASP program
% and that:
%   cr_rule_priority < cr_prefer_priority
%
% Currently, clingo 5.4.0 uses a signed 32-integer to represent numbers.
% Thus, (2 ** 32) / 2 - 1 == 2147483647 should be the highest number supported by the grounder.
% This number is unlikely to be used elsewhere in the program.

#const max_int = 2147483647.

#const cr_prefer_priority = max_int.
#const apia_policy_action_use_priority = max_int.
#const apia_policy_action_use_later_priority = max_int.
#const cr_rule_priority = max_int - 1.
#const aia_minimize_activity_length = max_int - 2.
