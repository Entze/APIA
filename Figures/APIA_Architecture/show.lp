%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #show statements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#show.
#show apply_cr_rule/1.

% ------------------------------------------------------------------------------------------

#show holds(Timestep, Fluent) :
    holds(Fluent, Timestep).
#show holds(Timestep, -Fluent) :
    -holds(Fluent, Timestep).

#show observed(Timestep, Fluent) :
    observed(Fluent, Timestep).
#show observed(Timestep, -Fluent) :
    -observed(Fluent, Timestep).

#show occurs(Timestep, Action) :
    occurs(Action, Timestep).
#show occurs(Timestep, -Action) :
    -occurs(Action, Timestep).

#show happened(Timestep, Action) :
    happened(Action, Timestep).
#show happened(Timestep, -Action) :
    -happened(Action, Timestep).

#show attempt(Timestep, Action) :
    attempt(Action, Timestep).
#show attempt(Timestep, -Action) :
    -attempt(Action, Timestep).

% ------------------------------------------------------------------------------------------

#show number_unobserved(Timestep, UnobservedActions) :
    number_unobserved(UnobservedActions, Timestep).

#show history_category(Timestep, category_1_history) :
    category_1_history(Timestep).
#show history_category(Timestep, category_2_history) :
    category_2_history(Timestep).
#show history_category(Timestep, category_3_history) :
    category_3_history(Timestep).
#show history_category(Timestep, category_4_history) :
    category_4_history(Timestep).

#show intended_action(Timestep, Action) :
    intended_action(Action, Timestep).

#show activity_component(Activity, ComponentIndex, Component) :
    activity_component(Activity, ComponentIndex, Component),
    Activity = ir.
#show activity_length(Activity, ActivityLength) :
    activity_length(Activity, ActivityLength),
    Activity = ir.
#show activity_goal(Activity, ActivityGoal) :
    activity_goal(Activity, ActivityGoal),
    Activity = ir.

% ------------------------------------------------------------------------------------------

#show permitted(Timestep, Action) :
    permitted(Action, Timestep).
#show permitted(Timestep, -Action) :
    -permitted(Action, Timestep).

#show obl(Timestep, "obligated to", Happening) :
    obl(Happening, Timestep).
#show obl(Timestep, "not obligated to", Happening) :
    -obl(Happening, Timestep).

#show prefer(Preferred, Other) :
    prefer(Preferred, Other).

#show auth_compliance(ComplianceLevel) :
    auth_compliance(ComplianceLevel).
#show auth_compliance(-ComplianceLevel) :
    -auth_compliance(ComplianceLevel).

#show obl_compliant(compliant) :
    obl_compliant.
#show obl_compliant(-compliant) :
    -obl_compliant.

#show obl_compliant(Timestep, compliant) :
    obl_compliant(Timestep).
#show obl_compliant(Timestep, -compliant) :
    -obl_compliant(Timestep).
