% Example file

%%%% Domains %%%%

a(A) :-
    A = 1..3.

b(B) :-
    B = 2..5.

c(C) :-
    C = 3.

%%%% Statics %%%%

foo(A) :-
    a(A).

%%%% Fluents %%%%

% bar(B)
fluent(inertial, bar(B)) :-
    b(B).

% baz(C)
fluent(defined, baz(C)) :-
    c(C).

%%%% Actions %%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

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

%%%% Action descriptions %%%%
#program action_description(current_timestep).

% do_bar(B) causes bar(B)
%   [if ...]
holds(bar(B), current_timestep + 1) :-
    occurs(do_bar(B), current_timestep).
    % [...]

% baz(B)
%   if bar(B), [...]
holds(baz(B), current_timestep) :-
    holds(bar(B), current_timestep).
    % [...]

% impossible do_foo(A), do_bar(B), do_baz(C)
%   if foo(A), bar(B), baz(C), A = B, B = C
-occurs(do_foo(A), current_timestep) | -occurs(do_bar(B), current_timestep) | -occurs(do_baz(C), current_timestep) :-
    foo(A),
    holds(bar(B), current_timestep),
    holds(baz(C), current_timestep).
