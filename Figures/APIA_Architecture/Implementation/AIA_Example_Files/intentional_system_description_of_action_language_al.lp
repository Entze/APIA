% Example file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a(A) :-
    A = 1..3.

b(B) :-
    B = 2..5.

c(C) :-
    C = 3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

foo(A) :-
    a(A).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% bar(B)
physical_fluent(inertial, bar(B)) :-
    b(B).

% baz(C)
physical_fluent(defined, baz(C)) :-
    c(C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions or exogenous actions (we assume actions cannot be both)

% do_foo(A)
physical_action(do_foo(A)) :-
    a(A).

agent_action(do_foo(A)) :-
    a(A).

% do_bar(B)
physical_action(do_bar(B)) :-
    b(B).

exogenous_action(do_bar(B)) :-
    b(B).

% do_baz(C)

physical_action(do_baz(C)) :-
    c(C).

agent_action(do_baz(C)) :-
    c(C).

exogenous_action(do_baz(C)) :-
    c(C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% do_bar(B) causes bar(B) [if
%   ...]
holds(bar(B), timestep + 1) :-
    occurs(do_bar(B), timestep).
    % [...]

% baz(B) if
%   bar(B),
%   [...]
holds(baz(B), timestep) :-
    holds(bar(B), timestep).
    % [...]

% impossible do_foo(A), do_bar(B), do_baz(C) if
%   foo(A),
%   bar(B),
%   baz(C),
%   A = B,
%   B = C
%
% Note: Create (N choose N - 1) rules
impossible(do_foo(A), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_bar(B), timestep),
    occurs(do_baz(C), timestep).

impossible(do_bar(B), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_foo(A), timestep),
    occurs(do_baz(C), timestep).

impossible(do_baz(C), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_foo(A), timestep),
    occurs(do_bar(B), timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Starting ID for generated activities
#const ir = 1.

% goal(Goal) :-
%     Goal = %* ... *%,
%
% activity(Activity) :-
%     Activity = 1.
%
% activity_goal(Activity, ActivityGoal) :-
%     Activity = 1,
%     ActivityGoal = %* ... *%.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 1,
%     Component = %* ... *%.
%
% activity_component(Activity, ComponentIndex, Component) :-
%     Activity = 1,
%     ComponentIndex = 2,
%     Component = %* ... *%.
%
% ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initial observations (before AIA control loop) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% See p. 50 of dissertation

-observed(bar(B), Timestep) :-
    Timestep = 0,
    b(B).

observed(baz(C), Timestep) :-
    Timestep = 0,
    c(C).
