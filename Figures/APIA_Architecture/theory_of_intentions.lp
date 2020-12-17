% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"

% G = goal
% M = activity

fluent(inertial, active_goal(G)).
fluent(inertial, status(Activity, K)).
fluent(defined, active(Activity)).
fluent(defined, child(M1, Activity)).
fluent(defined, child_goal(G1, G)).
fluent(defined, descendant(M1, Activity)).
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

% child(M1) if component(Activity, Activity + 1, M1), status(Activity, K)
holds(child(M1), I) :-
    step(I),
    holds(component(Activity, Activity + 1, M1), I),
    holds(status(Activity, K), I).

% child_goal(G1, G) if child(M1, Activity), goal(Activity, G), goal(M1, G1)
holds(child_goal(G1, G), I) :-
    step(I),
    holds(child(M1, Activity), I),
    holds(goal(Activity, G), I),
    holds(goal(M1, G1), I).

% descendant(M1, Activity) if child(M1, Activity)
holds(descendant(M1, Activity), I) :-
    step(I),
    holds(child(M1, Activity), I).

% descendant(M1, Activity) if descendant(M1, Activity), descendant(M2, M1)
holds(descendant(M1, Activity), I) :-
    step(I),
    holds(descendant(M1, Activity), I),
    holds(descendant(M2, M1), I).

% minor(M1) if child(M1, Activity)
holds(minor(M1), I) :-
    step(I),
    holds(child(M1, Activity), I).

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

% "An unachieved minor goal G1 of an activity M1 becomes active when M1 is the next component of an ongoing activity Activity"
% active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), goal(M1, G1), -G1, status(M1, -1)
holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    holds(active_goal(G), I),
    holds(goal(M1, G1), I),
    -holds(G1, I),
    holds(status(M1, -1), I).

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

% "A minor goal G1 of M1 is no longer active when M1 has been executed."
% -active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), -G1, goal(M1, G1), status(M1, K1), length(M1, K1)
-holds(active_goal(G1), I) :-
    step(I),
    holds(minor(G1), I),
    holds(child_goal(G1, G), I),
    holds(active_goal(G), I),
    -holds(G1, I),
    holds(goal(M1, G1), I),
    holds(status(M1, K1), I),
    holds(length(M1, K1), I).

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

% next_act(Activity, start(M1)) if status(Activity, K), component(Activity, K + 1, M1), in_progress(Activity), -active(M1)
holds(next_act(Activity, start(M1)), I) :-
    step(I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, M1), I),
    holds(in_progress(Activity), I),
    -holds(active(M1), I).

% next_act(Activity, A) if agent_action(A), status(Activity, K), component(Activity, K + 1, M1), in_progress(Activity), in_progress(M1), next_act(M1, A)
holds(next_act(Activity, A), I) :-
    step(I),
    agent_action(A),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, M1), I),
    holds(in_progress(Activity), I),
    holds(in_progress(M1), I),
    holds(next_act(M1, A), I).

% next_act(Activity, stop(M1)) if status(Activity, K), component(Activity, K + 1, M1), in_progress(Activity), active(M1), goal(M1, G1), -active_goal(G1)
holds(next_act(Activity, stop(M1)), I) :-
    step(I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, M1), I),
    holds(in_progress(Activity), I),
    holds(active(M1), I),
    holds(goal(M1, G1), I),
    -holds(active_goal(G1), I).

% A causes status(Activity, K + 1) if next_act(Activity, A), status(Activity, K), component(Activity, K + 1, A), physical_agent_action(A)
holds(status(Activity, K + 1), I + 1) :-
    step(I),
    occurs(A, I),
    holds(next_act(Activity, A), I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, A), I),
    physical_agent_action(A).

% stop(M1) causes status(Activity, K + 1) if status(Activity, K), component(Activity, K + 1, M1), next_act(Activity, stop(M1))
holds(status(Activity, K + 1), I + 1) :-
    step(I),
    occurs(stop(M1), I),
    holds(status(Activity, K), I),
    holds(component(Activity, K + 1, M1), I),
    holds(next_act(Activity, stop(M1)), I).

% stop(Activity) causes status(M1, -1) if descendant(M1, Activity)
holds(status(M1, -1), I + 1) :-
    step(I),
    occurs(stop(Activity), I),
    holds(descendant(M1, Activity), I).

% -next_name(Activity) if next_name(M1), Activity != M1
-holds(next_name(Activity), I) :-
    step(I),
    next_name(M1),
    % TODO: Bind Activity
    Activity != M1.

% start(Activity) causes next_name(Activity + 1) if next_name(Activity), -minor(Activity)
holds(next_name(Activity + 1), I + 1) :-
    step(I),
    occurs(start(Activity), I),
    holds(next_name(Activity), I),
    -holds(minor(Activity), I).
