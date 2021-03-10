%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% person(Person)
% agent(Person)
% employee(Person)
% department(Department)
% department(Person, Department)
% supervisor_to(Boss, Person)

higher_ranking_than(Boss, Person) :-
    supervisor_to(Boss, Person).

higher_ranking_than(HigherPerson, LowerPerson) :-
    higher_ranking_than(HigherPerson, MidPerson)
    supervisor_to(MidPerson, LowerPerson).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both


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
