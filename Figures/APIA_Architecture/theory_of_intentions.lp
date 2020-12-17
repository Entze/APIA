% Based on Blount et al. 2014. "Towards a Theory of Intentional Agents"

% G = goal
% M = activity

fluent(inertial, active_goal(G)).
fluent(inertial, status(M, K)).
fluent(defined, active(M)).
fluent(defined, child(M1, M)).
fluent(defined, child_goal(G1, G)).
fluent(defined, descendant(M1, M)).
fluent(defined, minor(M)).
fluent(defined, minor(G)).
fluent(defined, in_progress(M)).
fluent(defined, in_progress(G)).
fluent(defined, next_act(M, A))
fluent(inertial, next_name(M)).

mental_agent_action(Action) :-
    Action = (start(M); stop(M)).

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

% -status(M, K1) if status(M, K2), K1 != K2
-holds(status(M, K1), I) :-
    step(I),
    holds(status(M, K2), I),
    K1 != K2.

% active(M) if -status(M, -1)
holds(active(M), I) :-
    step(I),
    holds(status(M, -1), I).

% start(M) causes status(M, 0)
holds(start(M), I) :-
    step(I),
    holds(status(M, 0), I).

% stop(M) causes status(M, -1)
holds(stop(M), I) :-
    step(I),
    holds(status(M, -1), I).

% impossible start(M) if active(M)
-occurs(start(M), I) :-
    step(I),
    holds(active(M), I).

% impossible stop(M) if -active(M)
-occurs(stop(M), I) :-
    step(I),
    -holds(active(M), I).

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

% child(M1) if comp(M, M + 1, M1), status(M, K)
holds(child(M1), I) :-
    step(I),
    holds(comp(M, M + 1, M1), I),
    holds(status(M, K), I).

% child_goal(G1, G) if child(M1, M), goal(M, G), goal(M1, G1)
holds(child_goal(G1, G), I) :-
    step(I),
    holds(child(M1, M), I),
    holds(goal(M, G), I),
    holds(goal(M1, G1), I).

% descendant(M1, M) if child(M1, M)
holds(descendant(M1, M), I) :-
    step(I),
    holds(child(M1, M), I).

% descendant(M1, M) if descendant(M1, M), descendant(M2, M1)
holds(descendant(M1, M), I) :-
    step(I),
    holds(descendant(M1, M), I),
    holds(descendant(M2, M1), I).

% minor(M1) if child(M1, M)
holds(minor(M1), I) :-
    step(I),
    holds(child(M1, M), I).

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

% "An unachieved minor goal G1 of an activity M1 becomes active when M1 is the next component of an ongoing activity M"
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

% in_progress(M) if active(M), goal(M, G), active_goal(G)
holds(in_progress(M), I) :-
    step(I),
    holds(active(M), I),
    holds(goal(M, G), I),
    holds(active_goal(G), I).

% in_progress(G) if active(M), goal(M, G), active_goal(G)
holds(in_progress(G), I) :-
    step(I),
    holds(active(M), I),
    holds(goal(M, G), I),
    holds(active_goal(G), I).

% next_act(M, A) if physical_agent_action(A), status(M, K), comp(M, K + 1, A), in_progress(M)
holds(next_act(M, A), I) :-
    step(I),
    physical_agent_action(A),
    holds(status(M, K), I),
    holds(comp(M, K + 1, A), I),
    holds(in_progress(M), I).

% next_act(M, start(M1)) if status(M, K), comp(M, K + 1, M1), in_progress(M), -active(M1)
holds(next_act(M, start(M1)), I) :-
    step(I),
    holds(status(M, K), I),
    holds(comp(M, K + 1, M1), I),
    holds(in_progress(M), I),
    -holds(active(M1), I).

% next_act(M, A) if agent_action(A), status(M, K), comp(M, K + 1, M1), in_progress(M), in_progress(M1), next_act(M1, A)
holds(next_act(M, A), I) :-
    step(I),
    agent_action(A),
    holds(status(M, K), I),
    holds(comp(M, K + 1, M1), I),
    holds(in_progress(M), I),
    holds(in_progress(M1), I),
    holds(next_act(M1, A), I).

% next_act(M, stop(M1)) if status(M, K), comp(M, K + 1, M1), in_progress(M), active(M1), goal(M1, G1), -active_goal(G1)
holds(next_act(M, stop(M1)), I) :-
    step(I),
    holds(status(M, K), I),
    holds(comp(M, K + 1, M1), I),
    holds(in_progress(M), I),
    holds(active(M1), I),
    holds(goal(M1, G1), I),
    -holds(active_goal(G1), I).

% A causes status(M, K + 1) if next_act(M, A), status(M, K), comp(M, K + 1, A), physical_agent_action(A)
holds(status(M, K + 1), I + 1) :-
    step(I),
    occurs(A, I),
    holds(next_act(M, A), I),
    holds(status(M, K), I),
    holds(comp(M, K + 1, A), I),
    physical_agent_action(A).

% stop(M1) causes status(M, K + 1) if status(M, K), comp(M, K + 1, M1), next_act(M, stop(M1))
holds(status(M, K + 1), I + 1) :-
    step(I),
    occurs(stop(M1), I),
    holds(status(M, K), I),
    holds(comp(M, K + 1, M1), I),
    holds(next_act(M, stop(M1)), I).

% stop(M) causes status(M1, -1) if descendant(M1, M)
holds(status(M1, -1), I + 1) :-
    step(I),
    occurs(stop(M), I),
    holds(descendant(M1, M), I).

% -next_name(M) if next_name(M1), M != M1
-holds(next_name(M), I) :-
    step(I),
    next_name(M1),
    % TODO: Bind M
    M != M1.

% start(M) causes next_name(M + 1) if next_name(M), -minor(M)
holds(next_name(M + 1), I + 1) :-
    step(I),
    occurs(start(M), I),
    holds(next_name(M), I),
    -holds(minor(M), I).
