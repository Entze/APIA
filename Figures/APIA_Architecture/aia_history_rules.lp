% See p. 57 of dissertation

% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

#program aia_history_rules(current_timestep).

component(Action) :-
    physical_action(Action),
    agent_action(Action).

component(Activity) :-
    activity(Activity).

equal(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    goal(Goal),
    activity_goal(Activity, Goal),
    activity_goal(OtherActivity, Goal),
    equal_plan(Activity, OtherActivity).

equal_plan(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    activity_length(Activity, ActivityLength),
    activity_length(OtherActivity, ActivityLength),
    not different_component(Activity, OtherActivity).

different_component(Activity, OtherActivity) :-
    activity(Activity),
    activity(OtherActivity),
    component(ActivityComponent),
    component(OtherActivityComponent),
    index(ActivityIndex),
    activity_component(Activity, ActivityIndex, ActivityComponent),
    activity_component(OtherActivity, ActivityIndex, OtherActivityComponent),
    ActivityComponent != OtherActivityComponent.

:-
    activity(Activity),
    activity(OtherActivity),
    equal(Activity, OtherActivity),
    Activity != OtherActivity.

%%%% Initialization Axiom %%%%
%
% See p. 58 of dissertation
#program base.

holds(Fluent, Timestep) :-
    observed(Fluent, Timestep),
    Timestep = 0.

-holds(Fluent, Timestep) :-
    -observed(Fluent, Timestep),
    Timestep = 0.

%%%% Reality Check Axioms %%%%
%
% See p. 58 of dissertation
#program aia_history_rules(current_timestep).

:-
    observed(Fluent, Timestep),
    Timestep <= current_timestep,
    -holds(Fluent, Timestep).

:-
    -observed(Fluent, Timestep),
    Timestep <= current_timestep,
    holds(Fluent, Timestep).

%%%% Occurrence-Awareness Axiom %%%%
%
% See p. 58 of dissertation
#program aia_history_rules(current_timestep).

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    happened(Action, Timestep).

-occurs(Action, Timestep) :-
    Timestep < current_timestep,
    -happened(Action, Timestep).

%%%% Misc %%%%
%
% See p. 59 of dissertation

occurs(Action, Timestep) :-
    Timestep < current_timestep,
    attempt(Action, Timestep),
    not impossible(Action, Timestep).

:-
    Timestep < current_timestep,
    agent_action(Action),
    occurs(Action, Timestep),
    not attempt(Action, Timestep).

%%%% Pre-model rules %%%%
%
% See p. 59 of dissertation

impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    goal(OtherGoal),
    occurs(select(OtherGoal), Timestep),
    Goal != OtherGoal.

impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    activity(Activity),
    holds(active_activity(Activity), Timestep).

impossible(select(Goal), Timestep) :-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    holds(active_goal(Goal), Timestep).

%%%%
%
% See p. 60 of dissertation
%
% TODO: Should these be observed() statements due to legality definition
% on (p. 40) of dissertation?

holds(activity_status(Activity, ActivityIndex), Timestep) :-
    activity(Activity),
    Timestep = 0,
    ActivityIndex = -1.

-holds(active_goal(Goal), Timestep) :-
    goal(Goal),
    Timestep = 0.

% Determines the next ID for generated activities
holds(next_name(ir), Timestep) :-
    Timestep = 0.

%%%% Applicability constraints %%%%
%
% "the agent always observes the results of
%   - his attempts to perform actions,
%   - occurrences of actions performed by his controller,
%   - the truth value of his goal."
% (p. 60) of dissertation

observed_result(Action, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    agent_action(Action),
    happened(Action, Timestep).

observed_result(Action, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    agent_action(Action),
    -happened(Action, Timestep).

:-
    step(Timestep),
    Timestep <= current_timestep,
    attempt(Action, Timestep),
    agent_action(Action),
    not observed_result(Action, Timestep).

:-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    occurs(select(Goal), Timestep),
    not happened(select(Goal), Timestep).

:-
    step(Timestep),
    Timestep < current_timestep,
    goal(Goal),
    occurs(abandon(Goal), Timestep),
    not happened(abandon(Goal), Timestep).

need_to_observe_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    % -holds(minor_goal(Goal), Timestep - 1),  % From AIA implementation
    holds(active_goal(Goal), Timestep - 1).

need_to_observe_goal(ChildGoal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    activity(ChildActivity),
    goal(Goal),
    goal(ChildGoal),
    activity_goal(ChildActivity, ChildGoal),
    holds(immediate_child_goal(ChildGoal, Goal), Timestep),
    holds(active_goal(Goal), Timestep).

observed_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    observed(Goal, Timestep).

observed_goal(Goal, Timestep) :-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    -observed(Goal, Timestep).

:-
    step(Timestep),
    Timestep <= current_timestep,
    goal(Goal),
    need_to_observe_goal(Goal, Timestep),
    not observed_goal(Goal, Timestep).

%%%% Model rules %%%%
%
% See p. 61 of dissertation

{ apply_cr_rule(diagnosis(Action, Timestep, current_timestep)) } :-
    Timestep = 0..current_timestep,
    physical_action(Action),
    exogenous_action(Action),
    Timestep < current_timestep.

occurs(Action, Timestep) :-
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).

%%%%
%
% See p. 62 of dissertation

unobserved(Action, Timestep) :-
    Timestep < current_timestep,
    physical_action(Action),  % TODO: In paper, but not AIA
    exogenous_action(Action),
    occurs(Action, Timestep),
    not happened(Action, Timestep).

number_unobserved(UnobservedActions, current_timestep) :-
    UnobservedActions = #count{ Action : unobserved(Action, current_timestep) }.
