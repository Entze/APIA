%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% computer(Computer)
% cellphone(Cellphone)
% computer_has(Computer, cd_drive)
% location(computer(Computer), location(Location))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fluent(inertial, computer_on(Computer)) :-
    computer(Computer).

fluent(inertial, cd_drive_full(Computer)) :-
    computer_has(Computer, cd_drive).

fluent(inertial, chair_count(Location, Chairs)) :-
    location(Location),
    Chairs = 0..12.  % TODO: Parameterize this value

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

% pick_up_phone(Actor, Cellphone)
physical_action(pick_up_phone(Actor, Cellphone)) :-
    agent(Actor).

agent_action(pick_up_phone(Actor, Cellphone)) :-
    agent(Actor).

exogenous_action(pick_up_phone(Actor, Cellphone)) :-
    person(Actor),
    not agent(Actor).

% drop_off_phone(Actor, Cellphone)
physical_action(drop_off_phone(Actor, Cellphone)) :-
    agent(Actor).

agent_action(drop_off_phone(Actor, Cellphone)) :-
    agent(Actor).

exogenous_action(drop_off_phone(Actor, Cellphone)) :-
    person(Actor),
    not agent(Actor).

% pick_up_cd(Actor, CD)
physical_action(pick_up_cd(Actor, CD)) :-
    agent(Actor).

agent_action(pick_up_cd(Actor, CD)) :-
    agent(Actor).

exogenous_action(pick_up_cd(Actor, CD)) :-
    person(Actor),
    not agent(Actor).

% put_down_cd(Actor, CD)
physical_action(put_down_cd(Actor, CD)) :-
    agent(Actor).

agent_action(put_down_cd(Actor, CD)) :-
    agent(Actor).

exogenous_action(put_down_cd(Actor, CD)) :-
    person(Actor),
    not agent(Actor).

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
