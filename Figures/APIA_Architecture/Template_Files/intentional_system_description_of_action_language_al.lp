% Example file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a(A) :-
    A = 1..3.

b(B) :-
    B = 2..5.

c(C) :-
    C = 3.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person(Person) :-
    Person = (
        "Alice";
        "Bob"
    ).

agent(Person) :-
    person(Person),
    Person = "Alice".

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

% do_foo(Actor, A)
physical_action(do_foo(Actor, A)) :-
    person(Actor),
    a(A).
agent_action(do_foo(Actor, A)) :-
    physical_action(do_foo(Actor, A)),
    agent(Actor).

exogenous_action(do_foo(Actor, A)) :-
    physical_action(do_foo(Actor, A)),
    not agent(Actor).

% do_bar(Actor, B)
physical_action(do_bar(Actor, B)) :-
    b(B).

agent_action(do_bar(Actor, B)) :-
    physical_action(do_bar(Actor, B)),
    agent(Actor).

exogenous_action(do_bar(Actor, B)) :-
    physical_action(do_bar(Actor, B)),
    not agent(Actor).

% do_baz(Actor, C)
physical_action(do_baz(Actor, C)) :-
    c(C).

agent_action(do_baz(Actor, C)) :-
    physical_action(do_baz(Actor, C)),
    agent(Actor).

exogenous_action(do_baz(Actor, C)) :-
    physical_action(do_baz(Actor, C)),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% do_bar(Actor, B) causes bar(B) [if
%   ...]
holds(bar(B), timestep + 1) :-
    occurs(do_bar(Actor, B), timestep).
    % [...]

% baz(B) if
%   bar(B),
%   [...]
holds(baz(B), timestep) :-
    holds(bar(B), timestep).
    % [...]

% impossible do_foo(Actor, A), do_bar(Actor, B), do_baz(Actor, C) if
%   foo(A),
%   bar(B),
%   baz(C),
%   A = B,
%   B = C
%
% Note: Create (N choose N - 1) rules
impossible(do_foo(Actor, A), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_bar(Actor, B), timestep),
    occurs(do_baz(Actor, C), timestep).

impossible(do_bar(Actor, B), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_foo(Actor, A), timestep),
    occurs(do_baz(Actor, C), timestep).

impossible(do_baz(Actor, C), timestep) :-
    foo(A),
    holds(bar(B), timestep),
    holds(baz(C), timestep),
    A = B,
    B = C,
    occurs(do_foo(Actor, A), timestep),
    occurs(do_bar(Actor, B), timestep).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Activities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Starting ID for generated activities
#const ir = 1.

% goal(Goal) :-
%     Goal = %* ... *%,
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
