#show.
#show number_unobserved/2.
#show intended_action/2.
#show futile_goal/2.

% -----------------------------------------
#program apia_show_terms(current_timestep).

#show diagnosis(Action, Timestep, current_timestep) :
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).
