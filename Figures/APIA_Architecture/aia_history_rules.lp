% See p. 57 of dissertation

% fluent(inertial, Fluent)
% fluent(defined, Fluent)
% aciton(Action)
% happened(Action, Timestep)
% observed(Fluent, Timestep)

#program aia_history_rules(current_timestep).

comp(PAA) :-
    physical_action(PAA),
    agent_action(PAA).

comp(Activity) :-
    activity(Activity).

equal(Activity, M1) :-
    activity(Activity),
    activity(M1),
    goal(Goal),
    goal(Activity, Goal),
    goal(M1, Goal),
    equal_plan(Activity, M1).

equal_plan(Activity, M1) :-
    activity(Activity),
    activity(M1),
    length(Activity, L),
    length(M1, L),
    not different_component(Activity, M1).

different_component(Activity, M1) :-
    activity(Activity),
    activity(M1),
    comp(ActivityComponent),
    comp(C1),
    index(ActivityIndex),
    component(Activity, ActivityIndex, ActivityComponent),
    component(M1, ActivityIndex, C1),
    ActivityComponent != C1.

:-
    activity(Activity),
    activity(M1),
    equal(Activity, M1),
    Activity != M1.

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

impossible(select(Goal), I) :-
    step(I),
    I < current_timestep,
    goal(Goal),
    goal(G1),
    occurs(select(G1), I),
    Goal != G1.

impossible(select(Goal), I) :-
    step(I),
    I < current_timestep,
    goal(Goal),
    activity(Activity),
    holds(active(Activity), I).

impossible(select(Goal), I) :-
    step(I),
    I < current_timestep,
    goal(Goal),
    holds(active_goal(Goal), I).

%%%%
%
% See p. 60 of dissertation

holds(status(Activity, -1), Timestep) :-
    activity(Activity),
    Timestep = 0.

-holds(active_goal(Goal), Timestep) :-
    goal(Goal),
    Timestep = 0.

holds(next_name(ir), Timestep) :-
    Timestep = 0.

%%%% Applicability constraints %%%%
%
% "the agent always observes the results of
%   - his attempts to perform actions,
%   - occurrences of actions performed by his controller,
%   - the truth value of his goal."
% (p. 60) of dissertation

observed_result(AA, I) :-
    step(I),
    I <= current_timestep,
    agent_action(AA),
    happened(AA, I).

observed_result(AA, I) :-
    step(I),
    I <= current_timestep,
    agent_action(AA),
    -happened(AA, I).

:-
    step(I),
    I <= current_timestep,
    attempt(AA, I),
    agent_action(AA),
    not observed_result(AA, I).

:-
    step(I),
    I < current_timestep,
    goal(Goal),
    occurs(select(Goal), I),
    not happened(select(Goal), I).

:-
    step(I),
    I < current_timestep,
    goal(Goal),
    occurs(abandon(Goal), I),
    not happened(abandon(Goal), I).

need_to_observe_goal(Goal, I) :-
    step(I),
    I <= current_timestep,
    goal(Goal),
    % -holds(minor(Goal), I - 1),  % From AIA implementation
    holds(active_goal(Goal), I - 1).

need_to_observe_goal(G1, I) :-
    step(I),
    I <= current_timestep,
    activity(M1),
    goal(Goal),
    goal(G1),
    goal(M1, G1),
    holds(immediate_child_goal(G1, Goal), I),
    holds(active_goal(Goal), I).

observed_goal(Goal, I) :-
    step(I),
    I <= current_timestep,
    goal(Goal),
    observed(Goal, I).

observed_goal(Goal, I) :-
    step(I),
    I <= current_timestep,
    goal(Goal),
    -observed(Goal, I).

:-
    step(I),
    I <= current_timestep,
    goal(Goal),
    need_to_observe_goal(Goal, I),
    not observed_goal(Goal, I).

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

:~
    apply_cr_rule(diagnosis(Action, Timestep, current_timestep)).
    [1@1, diagnosis(Action, Timestep, current_timestep)]

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
