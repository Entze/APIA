#show number_unobserved/2.
#show intended_action/2.
#show futile_goal/2.

% -----------------------------------------
#program apia_show_terms(current_timestep).

#show diagnosis(Action, Timestep, current_timestep) :
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).

#show activity_component(ir, ComponentIndex, Component) :
    activity_component(ir, ComponentIndex, Component).
#show activity_length(ir, ActivityLength) :
    activity_length(ir, ActivityLength).
#show activity_goal(ir, ActivityGoal) :
    activity_goal(ir, ActivityGoal).
