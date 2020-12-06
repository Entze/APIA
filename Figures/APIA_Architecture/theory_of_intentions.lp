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

% active(M) if -status(M, -1)

% start(M) causes status(M, 0)

% stop(M) causes status(M, -1)

% impossible start(M) if active(M)

% impossible stop(M) if -active(M)

% If the agent performs a mental action, then it must be the only action it is performing at the timestep.
% impossible A1, A2 if physical_agent_action(A1), mental_agent_action(A2)
% impossible A1, A2 if mental_agent_action(A1), mental_agent_action(A2), A1 != A2.

% If the agent performs wait, then it must be the only action it is performing at the timestep.
% impossible wait, A if physical_agent_action(A).
% impossible wait, A if mental_agent_action(A).

% child(M1) if comp(M, M + 1, M1), status(M, K)

% child_goal(G1, G) if child(M1, M), goal(M, G), goal(M1, G1)

% descendant(M1, M) if child(M1, M)

% descendant(M1, M) if descendant(M1, M),  descendant(M2, M1)

% minor(M1) if child(M1, M)

% minor(G1) if child_goal(G1, G)

% select(G) causes active_goal(G)

% impossible select(G) if active_goal(G)

% abandon(G) causes -active_goal(G)

% impossible abandon(G) if -active_goal(G)

% impossible abandon(G) if minor(G)

% "We assume that no physical exogenous action may occur concurrently with a speical exogenous action"
% impossible A1, A1 if special_exogenous_action(A1), physical_exogenous_action(A2)
% impossible A1, A1 if special_exogenous_action(A1), physical_agent_action(A2)
% impossible A1, A1 if special_exogenous_action(A1), mental_agent_action(A2)

% -active_goal(G) if -minor(G), goal(G)

%%%% Sub goal %%%%

% "An unachieved minor goal G1 of an activity M1 becomes active when M1 is the next component of an ongoing activity M"
% active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), goal(M1, G1), -G1, status(M1, -1)

% "A minor goal G1 is no longer active when it is achieved."
% -active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), G1.

% "A minor goal G1 is no longer active when its parent [goal] is no longer active"
% -active_goal(G1) if minor(G1), child_goal(G1, G), -active_goal(G)

% "A minor goal G1 of M1 is no longer active when M1 has been executed."
% -active_goal(G1) if minor(G1), child_goal(G1, G), active_goal(G), -G1, goal(M1, G1), status(M1, K1), length(M1, K1)

%%%% Misc. %%%%

% in_progress(M) if active(M), goal(M, G), active_goal(G)

% in_progress(G) if active(M), goal(M, G), active_goal(G)

% next_act(M, A) if physical_agent_action(A), status(M, K), comp(M, K + 1, A), in_progress(M)

% next_act(M, start(M1)) if status(M, K), comp(M, K + 1, M1), in_progress(M), -active(M1)

% next_act(M, A) if agent_action(A), status(M, K), comp(M, K + 1, M1), in_progress(M), in_progress(M1), next_act(M1, A)

% next_act(M, stop(M1)) if status(M, K), comp(M, K + 1, M1), in_progress(M), active(M1), goal(M1, G1), -active_goal(G1)

% A causes status(M, K + 1) if next_act(M, A), status(M, K), comp(M, K + 1, A), physical_agent_action(A)

% stop(M1) causes status(M, K + 1) if status(M, K), comp(M, K + 1, M1), next_act(M, stop(M1))

% stop(M) causes status(M1, -1) if descendant(M1, M)

% -next_name(M) if next_name(M1), M != M1

% start(M) causes next_name(M + 1) if next_name(M), -minor(M)
