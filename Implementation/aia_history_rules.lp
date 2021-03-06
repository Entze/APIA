% See p. 57 of dissertation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sanity Check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_sanity_checks(current_timestep, max_activity_length).

% "Activities must be unique (i.e. there are no two activities with the same goal and plan)"
% (p. 57) of dissertation

component(Action) :-
    agent_action(Action),
    not mental_action(Action).  % Note: Our modification to consider policy actions

% (p. 57) of dissertation
component(Activity) :-
    activity(Activity).

% (p. 57) of dissertation
%
% Note: Originally: equal(Activity, OtherActivity)
equal_activity(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    Activity != OtherActivity,  % Note: Our addition
    goal(Goal),
    activity_goal(Activity, Goal),
    activity_goal(OtherActivity, Goal),
    equal_plan(Activity, OtherActivity).

% (p. 57) of dissertation
equal_plan(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    Activity != OtherActivity,  % Note: Our addition
    activity_length(Activity, ActivityLength),
    activity_length(OtherActivity, ActivityLength),
    not different_component(Activity, OtherActivity).

% Note: We update this rule to address concurrent actions
% (p. 57) of dissertation
%
% Let K be an activity index
% Let A' be the set of elementary actions at the K-th index of activity A
% Let B' be the set of elementary actions at the K-th index of activity B
%
% We want to derive this rule head when A' != B'
%
% Derivation in propositional logic:
%
%     A' != B' === neg(A' == B')
%              === neg(A subseteq B ^ B subseteq A)
%              === neg[forall x in A (x in B) ^ forall x in B (x in A)]
%              === [exists x in A (x not in B) or exists x in B (x not in A)]
different_component(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    Activity != OtherActivity,  % Note: Our addition
    component(ActivityComponent),
    ActivityIndex = 1..max_activity_length,
    activity_component(Activity, ActivityIndex, ActivityComponent),
    not activity_component(OtherActivity, ActivityIndex, ActivityComponent).

different_component(Activity, OtherActivity) :-
    different_component(OtherActivity, Activity).

% (p. 57) of dissertation
:-
    activity(Activity),
    activity(OtherActivity),
    equal_activity(Activity, OtherActivity),
    Activity != OtherActivity.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialization Axiom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.

% (p. 58) of dissertation
holds(Fluent, Timestep) :-
    observed(Fluent, Timestep),
    Timestep = 0.

% (p. 58) of dissertation
-holds(Fluent, Timestep) :-
    -observed(Fluent, Timestep),
    Timestep = 0.

% ------------------------------------------------------------------------------------------

% See p. 60 of dissertation

% (p. 60) of dissertation
%
% Note: Originally occurs(...).
%   Changed due to legality definition on (p. 40) of dissertation
observed(activity_status(Activity, ActivityIndex), Timestep) :-
    activity(Activity),
    Timestep = 0,
    ActivityIndex = -1.

% (p. 60) of dissertation
%
% Note: Originally occurs(...).
%   Changed due to legality definition on (p. 40) of dissertation
-observed(active_goal(Goal), Timestep) :-
    goal(Goal),
    Timestep = 0.

% Determines the next ID for generated activities
%
% (p. 60) of dissertation
%
% Note: Originally occurs(...).
%   Changed due to legality definition on (p. 40) of dissertation
observed(next_name(Activity), Timestep) :-
    Timestep = 0,
    Activity = ir.

% Note: Our addition
-observed(next_name(Activity), Timestep) :-
    Timestep = 0,
    activity(Activity),
    Activity != ir.

% ------------------------------------------------------------------------------------------

% Note: Our addition
observed(activity_status(Activity, ActivityIndex), Timestep) :-
    Timestep = 0,
    Activity = (ir; ir + 1),
    ActivityIndex = -1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Occurrence-Awareness Axiom %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_history_rules(current_timestep).

% "Guarantees that occurrences of actions that are observed to have happened
%  actually occur"
% (p. 58) of dissertation
occurs(Action, Timestep) :-
    Timestep < current_timestep,
    happened(Action, Timestep).

% "Guarantees that occurrences of actions that are observed not to have happened
%  actually do not occur"
% (p. 58) of dissertation
-occurs(Action, Timestep) :-
    Timestep < current_timestep,
    -happened(Action, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Misc %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_history_rules(current_timestep).

% "The following two rules guarantee that an observation that an agent action did not occur
%  is due to the violation of an executability condition for that action."
% (p. 59) of dissertation

% (p. 59) of dissertation
occurs(Action, Timestep) :-
    Timestep < current_timestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

% (p. 59) of dissertation
:-
    Timestep < current_timestep,
    agent_action(Action),
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pre-model rules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_history_rules(current_timestep).

% (p. 59) of dissertation
%
% Note: Similar to (eq. 3.15) on (p. 30)
%   and (eq. 3.16) on (p. 31)
impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    goal(OtherGoal),
    occurs(select(OtherGoal), Timestep),
    Goal != OtherGoal.

% (p. 59) of dissertation
impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    activity(Activity),
    holds(active_activity(Activity), Timestep).

% (p. 59) of dissertation
%
% Note: Similar to (eq. 3.16) on (p. 31)
impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    holds(active_goal(Goal), Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Applicability constraints %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_sanity_checks(current_timestep, max_activity_length).
%
% "the agent always observes the results of
%   - his attempts to perform actions,
%   - occurrences of actions performed by his controller,
%   - the truth value of his goal."
% (p. 60) of dissertation

% (p. 60) of dissertation
observed_result(Action, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    agent_action(Action),
    happened(Action, Timestep).

% (p. 60) of dissertation
observed_result(Action, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    agent_action(Action),
    -happened(Action, Timestep).

% (p. 60) of dissertation
:-
    step(Timestep),
    Timestep <= current_timestep,
    attempt(Action, Timestep),
    agent_action(Action),
    not observed_result(Action, Timestep).

% (p. 60) of dissertation
:-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    occurs(select(Goal), Timestep),
    not happened(select(Goal), Timestep).

% (p. 60) of dissertation
:-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    occurs(abandon(Goal), Timestep),
    not happened(abandon(Goal), Timestep).

% (p. 61) of dissertation
need_to_observe_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    % -holds(minor_goal(Goal), Timestep - 1),  % TODO: From AIA implementation
    holds(active_goal(Goal), Timestep - 1).

% (p. 61) of dissertation
need_to_observe_goal(ChildGoal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    activity(ChildActivity),
    goal(Goal),
    goal(ChildGoal),
    activity_goal(ChildActivity, ChildGoal),
    holds(child_goal(ChildGoal, Goal), Timestep),
    holds(active_goal(Goal), Timestep).

% (p. 61) of dissertation
observed_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    observed(Goal, Timestep).

% (p. 61) of dissertation
observed_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    -observed(Goal, Timestep).

% (p. 61) of dissertation
:-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    need_to_observe_goal(Goal, Timestep),
    not observed_goal(Goal, Timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Model rules %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program aia_history_rules(current_timestep).
%
% "The next rule corresponds to the condition from the definition of model
%  which limits the number of unobserved occurrences of exogenous actions
%  to the minimal number necessary to satisfy the observations.
%  This is found by the following cr-rule."
% (p. 61) of dissertation

{ apply_cr_rule(diagnosis(Action, Timestep, current_timestep)) } :-
    Timestep = 0..current_timestep,
    physical_action(Action),
    exogenous_action(Action),
    Timestep < current_timestep.

occurs(Action, Timestep) :-
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).

% Note: Our addition. Reduces number of possible worlds
%
% prefer(diagnosis(Action, NewerTimestep, current_timestep), diagnosis(Action, OlderTimestep, current_timestep))
:~
    physical_action(Action),
    exogenous_action(Action),

    NewerTimestep = 0..current_timestep,
    OlderTimestep = 0..current_timestep,
    OlderTimestep < NewerTimestep,

    HigherPriorityCRRule = diagnosis(Action, NewerTimestep, current_timestep),
    LowerPriorityCRRule = diagnosis(Action, OlderTimestep, current_timestep),

    % prefer(HigherPriorityCRRule, LowerPriorityCRRule)
    not apply_cr_rule(HigherPriorityCRRule),
    apply_cr_rule(LowerPriorityCRRule).
    [1@cr_prefer_priority, apply_cr_rule(HigherPriorityCRRule), apply_cr_rule(LowerPriorityCRRule)]

% ------------------------------------------------------------------------------------------

% "The last two rules are for determining the value of the flag by simply
%  counting the number of unobserved occurrences of physical exogenous actions"
% (p. 62) of dissertation

unobserved(Action, Timestep) :-
    Timestep < current_timestep,
    physical_action(Action),  % Note: In paper, but not AIA
    exogenous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, current_timestep) :-
    UnobservedActions = #count{ Action, Timestep : unobserved(Action, Timestep) }.
