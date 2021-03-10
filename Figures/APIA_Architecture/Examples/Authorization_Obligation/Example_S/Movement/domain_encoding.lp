%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

% move(Actor, ToLocation)
physical_action(move(Actor, ToLocation)) :-
    person(Actor),
    location(ToLocation).

agent_action(move(Actor, ToLocation)) :-
    person(Actor),
    agent(Actor),
    location(ToLocation).

exogenous_action(move(Actor, ToLocation)) :-
    person(Actor),
    not agent(Actor),
    location(ToLocation).

% stand(Actor)
physical_action(stand(Actor)) :-
    person(Actor).

agent_action(stand(Actor)) :-
    person(Actor),
    agent(Actor).

exogenous_action(stand(Actor)) :-
    person(Actor),
    not agent(Actor).

% sit_in_chair(Actor, ChairType)
physical_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor).

agent_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor),
    agent(Actor).

exogenous_action(sit_in_chair(Actor, ChairType)) :-
    person(Actor),
    not agent(Actor).

% unlock_door(Actor, Door)

% lock_door(Actor, Door)

% pick_up_phone(Actor, Cellphone)

% drop_off_phone(Actor, Cellphone)

% pick_up_cd(Actor, CD)

% put_down_cd(Actor, CD)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).


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
% activity_length(Activity, ActivityLength) :-
%     Activity = 1,
%     ActivityLength = #max{ ComponentIndex : activity_component(Activity, ComponentIndex, _) }.
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
