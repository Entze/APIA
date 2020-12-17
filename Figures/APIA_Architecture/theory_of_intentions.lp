% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"

% G = goal
% M = activity

fluent(inertial, active_goal(G)).
fluent(inertial, status(Activity, K)).
fluent(defined, active(Activity)).
fluent(defined, child(ChildActivity, Activity)).
fluent(defined, child_goal(G1, G)).
fluent(defined, descendant(ChildActivity, Activity)).
fluent(defined, minor(Activity)).
fluent(defined, minor(G)).
fluent(defined, in_progress(Activity)).
fluent(defined, in_progress(G)).
fluent(defined, next_act(Activity, A))
fluent(inertial, next_name(Activity)).

mental_agent_action(Action) :-
    Action = (start(Activity); stop(Activity)).

physical_agent_action(Action)

special_exogenous_action(Action) :-
    % Exogenous
    Action = (select(G); abandon(G)).

%action(Action) :-
%    physical_action(Action).
%
%action(Action) :-
%    mental_action(Action).

action(wait).

% -status(Activity, K1) if status(Activity, K2), K1 != K2
-holds(status(Activity, K1), I) :-
    step(I),
    holds(status(Activity, K2), I),
    K1 != K2.

% active(Activity) if -status(Activity, -1)
holds(active(Activity), I) :-
    step(I),
    holds(status(Activity, -1), I).

% start(Activity) causes status(Activity, 0)
holds(start(Activity), I) :-
    step(I),
    holds(status(Activity, 0), I).

% stop(Activity) causes status(Activity, -1)
holds(stop(Activity), I) :-
    step(I),
    holds(status(Activity, -1), I).

% impossible start(Activity) if active(Activity)
-occurs(start(Activity), I) :-
    step(I),
    holds(active(Activity), I).

% impossible stop(Activity) if -active(Activity)
-occurs(stop(Activity), I) :-
    step(I),
    -holds(active(Activity), I).

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible A1, A2 if physical_agent_action(A1), mental_agent_action(A2)
-occurs(A1, I) | -occurs(A2, I) :-
    step(I),
    physical_agent_action(A1),
    mental_agent_action(A2).

% impossible A1, A2 if mental_agent_action(A1), mental_agent_action(A2), A1 != A2.
-occurs(A1, I) | -occurs(A2, I) :-
    step(I),
    mental_agent_action(A1),
    mental_agent_action(A2),
    A1 != A2.

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, A if physical_agent_action(A).
-occurs(wait, I) | -occurs(A, I) :-
    step(I),
    physical_agent_action(A).

% impossible wait, A if mental_agent_action(A).
-occurs(wait, I) | -occurs(A, I) :-
    step(I),
    mental_agent_action(A).

% child(ChildActivity) if component(Activity, Activity + 1, ChildActivity), status(Activity, K)
holds(child(ChildActivity), I) :-
    step(I),
    holds(component(Activity, Activity + 1, ChildActivity), I),
    holds(status(Activity, K), I).

% child_goal(G1, G) if child(ChildActivity, Activity), goal(Activity, G), goal(ChildActivity, G1)
holds(child_goal(G1, G), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I),
    holds(goal(Activity, G), I),
    holds(goal(ChildActivity, G1), I).

% descendant(ChildActivity, Activity) if child(ChildActivity, Activity)
holds(descendant(ChildActivity, Activity), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I).

% descendant(ChildActivity, Activity) if descendant(ChildActivity, Activity), descendant(M2, ChildActivity)
holds(descendant(ChildActivity, Activity), I) :-
    step(I),
    holds(descendant(ChildActivity, Activity), I),
    holds(descendant(M2, ChildActivity), I).

% minor(ChildActivity) if child(ChildActivity, Activity)
holds(minor(ChildActivity), I) :-
    step(I),
    holds(child(ChildActivity, Activity), I).

% minor(G1) if child_goal(G1, G)
holds(minor(G1), I) :-
    step(I),
    holds(child_goal(G1, G), I).

% select(G) causes active_goal(G)
holds(active_goal(G), I + 1) :-
    step(I),
    occurs(select(G), I).

% impossible select(G) if active_goal(G)
-occurs(select(G), I) :-
    step(I),
    holds(active_goal(G), I).

% abandon(G) causes -active_goal(G)
-holds(active_goal(G), I + 1) :-
    step(I),
    occurs(abandon(G), I).

% impossible abandon(G) if -active_goal(G)
-occurs(abandon(G), I) :-
    -holds(active_goal(G), I).

% impossible abandon(G) if minor(G)
-occurs(abandon(G), I) :-
    -holds(minor(G), I).

% "We assume that no physical exogenous action may occur concurrently with a speical exogenous action"
% impossible A1, A2 if special_exogenous_action(A1), physical_exogenous_action(A2)
-occurs(A1, I) | -occurs(A2, I) :-
    step(I),
    special_exogenous_action(A1),
    physical_exogenous_action(A2).

% impossible A1, A2 if special_exogenous_action(A1), physical_agent_action(A2)
-occurs(A1, I) | -occurs(A2, I) :-
    step(I),
    special_exogenous_action(A1),
    physical_agent_action(A2).

% impossible A1, A2 if special_exogenous_action(A1), mental_agent_action(A2)
-occurs(A1, I) | -occurs(A2, I) :-
    step(I),
    special_exogenous_action(A1),
    mental_agent_action(A2).

% -active_goal(G) if -minor(G), goal(G)
-holds(active_goal(G), I) :-
    step(I),
    -holds(minor(G), I),
    holds(goal(G), I).

%%%% Sub goal %%%%

% "An unachieved minor goal G1 of an activity ChildActivity becomes active when ChildActivity is the next component of an ongoing activity Activity"
% active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), goal(ChildActivity, G1), -G1, status(ChildActivity, -1)
holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    holds(active_goal(G), I),
    holds(goal(ChildActivity, G1), I),
    -holds(G1, I),
    holds(status(ChildActivity, -1), I).

% "A minor goal G1 is no longer active when it is achieved."
% -active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), G1.
-holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    holds(active_goal(G), I),
    holds(G1, I).

% "A minor goal G1 is no longer active when its parent [goal] is no longer active"
% -active_goal(G1) if minor(G1), child_goal(G1, G), -active_goal(G)
-holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    -holds(active_goal(G), I).

% "A minor goal G1 of ChildActivity is no longer active when ChildActivity has been executed."
% -active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), -G1, goal(ChildActivity, G1), status(ChildActivity, K1), length(ChildActivity, K1)
-holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    holds(active_goal(G), I),
    -holds(G1, I),
    holds(goal(ChildActivity, G1), I),
    holds(status(ChildActivity, K1), I),
    holds(length(ChildActivity, K1), I).

%%%% Misc. %%%%

% in_progress(Activity) if active(Activity), goal(Activity, G), active_goal(G)
holds(in_progress(Activity), I) :-
    step(I),
    holds(active(Activity), I),
    holds(goal(Activity, G), I),
    holds(active_goal(G), I).

% in_progress(G) if active(Activity), goal(Activity, G), active_goal(G)
holds(in_progress(G), I) :-
    step(I),
    holds(active(Activity), I),
    holds(goal(Activity, G), I),
    holds(active_goal(G), I).

% next_act(Activity, A) if physical_agent_action(A), status(Activity, K), component(Activity, K + 1, A), in_progress(Activity)
holds(next_act(Activity, A), I) :-
    step(I),
    physical_agent_action(A),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, A), I),
    holds(in_progress(Activity), I).

% next_act(Activity, start(ChildActivity)) if status(Activity, K), component(Activity, K + 1, ChildActivity), in_progress(Activity), -active(ChildActivity)
holds(next_act(Activity, start(ChildActivity)), I) :-
    step(I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    -holds(active(ChildActivity), I).

% next_act(Activity, A) if agent_action(A), status(Activity, K), component(Activity, K + 1, ChildActivity), in_progress(Activity), in_progress(ChildActivity), next_act(ChildActivity, A)
holds(next_act(Activity, A), I) :-
    step(I),
    agent_action(A),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    holds(in_progress(ChildActivity), I),
    holds(next_act(ChildActivity, A), I).

% next_act(Activity, stop(ChildActivity)) if status(Activity, K), component(Activity, K + 1, ChildActivity), in_progress(Activity), active(ChildActivity), goal(ChildActivity, G1), -active_goal(G1)
holds(next_act(Activity, stop(ChildActivity)), I) :-
    step(I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, ChildActivity), I),
    holds(in_progress(Activity), I),
    holds(active(ChildActivity), I),
    holds(goal(ChildActivity, G1), I),
    -holds(active_goal(G1), I).

% A causes status(Activity, K + 1) if next_act(Activity, A), status(Activity, K), component(Activity, K + 1, A), physical_agent_action(A)
holds(status(Activity, K + 1), I + 1) :-
    step(I),
    occurs(A, I),
    holds(next_act(Activity, A), I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, A), I),
    physical_agent_action(A).

% stop(ChildActivity) causes status(Activity, K + 1) if status(Activity, K), component(Activity, K + 1, ChildActivity), next_act(Activity, stop(ChildActivity))
holds(status(Activity, K + 1), I + 1) :-
    step(I),
    occurs(stop(ChildActivity), I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, ChildActivity), I),
    holds(next_act(Activity, stop(ChildActivity)), I).

% stop(Activity) causes status(ChildActivity, -1) if descendant(ChildActivity, Activity)
holds(status(ChildActivity, -1), I + 1) :-
    step(I),
    occurs(stop(Activity), I),
    holds(descendant(ChildActivity, Activity), I).

% -next_name(Activity) if next_name(ChildActivity), Activity != ChildActivity
-holds(next_name(Activity), I) :-
    step(I),
    next_name(ChildActivity),
    % TODO: Bind Activity
    Activity != ChildActivity.

% start(Activity) causes next_name(Activity + 1) if next_name(Activity), -minor(Activity)
holds(next_name(Activity + 1), I + 1) :-
    step(I),
    occurs(start(Activity), I),
    holds(next_name(Activity), I),
    -holds(minor(Activity), I).
