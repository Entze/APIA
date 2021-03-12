%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fluents %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% busy_working(Person)
fluent(inertial, busy_working(Person)) :-
    person(Person).

% meeting_scheduled(Meeting)
fluent(inertial, meeting_scheduled(Meeting)) :-
    meeting(Meeting).

% meeting_classified(Meeting)
fluent(inertial, meeting_classified(Meeting)) :-
    meeting(Meeting).

% meeting_attendee(Meeting, Person)
fluent(inertial, meeting_attendee(Meeting, Person)) :-
    meeting(Meeting),
    person(Person).

% meeting_attendees_count(Meeting, AttendeeCount)
fluent(defined, meeting_attendees_count(Meeting, AttendeeCount)) :-
    meeting(Meeting),
    AttendeeCount = 0..5.

% meeting_all_attendees_present(Meeting)
fluent(defined, meeting_all_attendees_present(Meeting)) :-
    meeting(Meeting).

% meeting_all_attendees_not_busy(Meeting)
fluent(defined, meeting_all_attendees_not_busy(Meeting)) :-
    meeting(Meeting).

% meeting_held(Meeting)
fluent(inertial, meeting_held(Meeting)) :-
    meeting(Meeting).

% impromptu_meeting(Meeting)
fluent(defined, impromptu_meeting(Meeting)) :-
    meeting(Meeting).

% meeting_location(Meeting, Location)
fluent(inertial, meeting_location(Meeting, Location)) :-
    meeting(Meeting),
    location(Location).

% current_meeting(Meeting)
fluent(inertial, next_meeting(Meeting)) :-
    meeting(Meeting).

% next_meeting(Meeting)
fluent(defined, next_meeting(Meeting)) :-
    meeting(Meeting).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Actions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Requirements:
%   - All user-defined actions must be physical actions
%   - All user-defined actions must be either agent actions, exogenous actions, or both

% begin_working(Actor)
physical_action(begin_working(Actor)) :-
    agent(Actor).

agent_action(begin_working(Actor)) :-
    agent(Actor).

exogenous_action(begin_working(Actor)) :-
    agent(Actor).

% stop_working(Actor)
physical_action(stop_working(Actor)) :-
    agent(Actor).

agent_action(stop_working(Actor)) :-
    agent(Actor).

exogenous_action(stop_working(Actor)) :-
    agent(Actor).

% schedule_meeting(Actor, Meeting)
physical_action(schedule_meeting(Actor, Meeting)) :-
    agent(Actor).

agent_action(schedule_meeting(Actor, Meeting)) :-
    agent(Actor).

exogenous_action(schedule_meeting(Actor, Meeting)) :-
    person(Actor),
    not agent(Actor).

% classify_meeting(Actor, Meeting)
physical_action(classify_meeting(Actor, Meeting)) :-
    agent(Actor).

agent_action(classify_meeting(Actor, Meeting)) :-
    agent(Actor).

exogenous_action(classify_meeting(Actor, Meeting)) :-
    person(Actor),
    not agent(Actor).

% invite_to_meeting(Actor, Meeting, Person)
physical_action(invite_to_meeting(Actor, Meeting, Person)) :-
    agent(Actor).

agent_action(invite_to_meeting(Actor, Meeting, Person)) :-
    agent(Actor).

exogenous_action(invite_to_meeting(Actor, Meeting, Person)) :-
    person(Actor),
    not agent(Actor).

% hold_meeting(Actor, Meeting)
physical_action(hold_meeting(Actor, Meeting)) :-
    agent(Actor).

agent_action(hold_meeting(Actor, Meeting)) :-
    agent(Actor).

exogenous_action(hold_meeting(Actor, Meeting)) :-
    person(Actor),
    not agent(Actor).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% -----------------------------------------------------------------------

% begin_working(Actor)
%   causes busy_working(Actor)
holds(busy_working(Actor), timestep + 1) :-
    occurs(begin_working(Actor), timestep).

% impossible begin_working(Actor) if
%   busy_working(Actor)
impossible(begin_working(Actor), timestep) :-
    holds(busy_working(Actor), timestep).

% -----------------------------------------------------------------------

% stop_working(Actor)
%   causes -busy_working(Actor)
-holds(busy_working(Actor), timestep + 1) :-
    occurs(stop_working(Actor), timestep).

% impossible stop_working(Actor) if
%   -busy_working(Actor)
impossible(stop_working(Actor), timestep) :-
    -holds(busy_working(Actor), timestep).

% -----------------------------------------------------------------------

% schedule_meeting(Actor, Meeting)
%   causes meeting_scheduled(Meeting)
holds(meeting_scheduled(Meeting), timestep + 1) :-
    person(Actor),
    occurs(schedule_meeting(Actor, Meeting), timestep).

% schedule_meeting(Actor, Meeting)
%   causes current_meeting(Meeting)
holds(current_meeting(Meeting), timestep + 1) :-
    occurs(schedule_meeting(Actor, Meeting), timestep).

% next_meeting(Meeting + 1) if
%   current_meeting(Meeting)
holds(next_meeting(Meeting + 1), timestep) :-
    holds(current_meeting(Meeting), timestep).

% -next_meeting(OtherMeeting) if
%   next_meeting(Meeting),
%   OtherMeeting != Meeting.
-holds(next_meeting(OtherMeeting), timestep) :-
    holds(next_meeting(Meeting), timestep),
    OtherMeeting != Meeting.

% impossible schedule_meeting(Actor, Meeting) if
%   -next_meeting(Meeting)
-occurs(schedule_meeting(Actor, Meeting), timestep) :-
    -holds(next_meeting(Meeting), timestep).

% -----------------------------------------------------------------------

% classify_meeting(Actor, Meeting)
%   causes meeting_classified(Meeting)
holds(meeting_classified(Meeting), timestep + 1) :-
    occurs(classify_meeting(Actor, Meeting), timestep).

% impossible classify_meeting(Actor, Meeting) if
%   meeting_classified(Meeting)
impossible(classify_meeting(Actor, Meeting), timestep) :-
    meeting_classified(Meeting),

% -----------------------------------------------------------------------

% invite_to_meeting(Actor, Meeting, Person)
%   causes meeting_attendee(Meeting, Person)
holds(meeting_attendee(Meeting, Person), timestep + 1) :-
    occurs(invite_to_meeting(Actor, Meeting, Person), timestep).

% impossible invite_to_meeting(Actor, Meeting, Person) if
%   meeting_attendee(Meeting, Person)
impossible(invite_to_meeting(Actor, Meeting, Person), timestep) :-
    meeting_attendee(Meeting, Person),

% -----------------------------------------------------------------------

% -meeting_all_attendees_present(Meeting) if
%   agent(Agent),
%   person_location(Agent, AgentLocation),
%   meeting_attendee(Meeting, Person),
%   person_location(Person, Location),
%   AgentLocation != Location.
-holds(meeting_all_attendees_present(Meeting), timestep) :-
    agent(Agent),
    holds(person_location(Agent, AgentLocation), timestep),
    holds(meeting_attendee(Meeting, Person), timestep),
    holds(person_location(Person, Location), timestep),
    AgentLocation != Location.

% meeting_all_attendees_present(Meeting) if
%   -meeting_all_attendees_present(Meeting)
%
% (not-negative to positive closed-world assumption)
% (Axioms only provide not-positive to negative closed-world assumption)
holds(meeting_all_attendees_present(Meeting), timestep) :-
    meeting(Meeting),
    not -holds(meeting_all_attendees_present(Meeting), timestep).

% -----------------------------------------------------------------------

% -meeting_all_attendees_not_busy(Meeting) if
%   meeting_attendee(Meeting, Person),
%   busy_working(Person)
-holds(meeting_all_attendees_not_busy(Meeting), timestep) :-
    holds(meeting_attendee(Meeting, Person), timestep),
    holds(busy_working(Person), timestep).

% meeting_all_attendees_not_busy(Meeting) if
%   -meeting_all_attendees_not_busy(Meeting)
%
% (not-negative to positive closed-world assumption)
% (Axioms only provide not-positive to negative closed-world assumption)
holds(meeting_all_attendees_not_busy(Meeting), timestep) :-
    meeting(Meeting),
    not -holds(meeting_all_attendees_not_busy(Meeting), timestep).

% -----------------------------------------------------------------------

% hold_meeting(Actor, Meeting)
%   causes meeting_held(Meeting)
holds(meeting_held(Meeting), timestep + 1) :-
    occurs(hold_meeting(Actor, Meeting), timestep).

% hold_meeting(Actor, Meeting)
%   causes meeting_location(Meeting, Location)
%   if
%     person_location(Actor, Location)
holds(meeting_location(Meeting, Location), timestep + 1) :-
    person(Actor),
    occurs(hold_meeting(Actor, Meeting), timestep),
    holds(person_location(Actor, Location), timestep).

% -----------------------------------------------------------------------

% impromptu_meeting(Meeting) if
%   meeting_held(Meeting),
%   -meeting_scheduled(Meeting)
holds(impromptu_meeting(Meeting), timestep) :-
    holds(meeting_held(Meeting), timestep),
    -holds(meeting_scheduled(Meeting), timestep).

% -----------------------------------------------------------------------

% -meeting_location(Meeting, OtherLocation) if
%   meeting_location(Meeting, Location),
%   OtherLocation != Location.
-holds(meeting_location(Meeting, OtherLocation), timestep) :-
    holds(meeting_location(Meeting, Location), timestep),
    location(OtherLocation),
    OtherLocation != Location.

% -meeting_location(Meeting, Location) if
%   -meeting_held(Meeting)
-holds(meeting_location(Meeting, Location), timestep) :-
    -holds(meeting_held(Meeting), timestep),
    location(Location).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Normally, no one is allowed to hold a meeting until all attendees are present"
%
% normally -permitted(hold_meeting(Actor, Meeting)) if
%   -meeting_all_attendees_present(Meeting)
-permitted(hold_meeting(Actor, Meeting), timestep) :-
    agent(Actor),
    meeting(Meeting),
    -holds(meeting_all_attendees_present(Actor, Meeting), timestep),
    not permitted(hold_meeting(Actor, Meeting), timestep).

% "Normally, anyone is allowed to hold an impromptu meeting with a coworker if the coworker is not busy"
%
% normally permitted(hold_meeting(Actor, Meeting)) if
%   -meeting_scheduled(Meeting),
%   meeting_all_attendees_not_busy(Meeting)
permitted(hold_meeting(Actor, Meeting)) :-
    agent(Actor),
    -holds(meeting_scheduled(Meeting), timestep),
    holds(meeting_all_attendees_not_busy(Meeting), timestep),
    not -permitted(hold_meeting(Actor, Meeting)).

% "Normally, no one is allowed to hold an impromptu meeting with a coworker if he is busy"
%
% meeting_1: normally permitted(hold_meeting(Actor, Meeting)) if
%   -meeting_scheduled(Meeting),
%   -meeting_all_attendees_not_busy(Meeting)
permitted(hold_meeting(Actor, Meeting))  :-
    agent(Actor),
    -holds(meeting_scheduled(Meeting), timestep),
    -holds(meeting_all_attendees_not_busy(Meeting), timestep),
    not abnormal(meeting_1(Actor, Meeting)),
    not -permitted(hold_meeting(Actor, Meeting)) .

% "Normally, no one is allowed to invite a higher-ranking employee to an impromptu meeting if he is busy"
%
% meeting_2: normally -permitted(invite_to_meeting(Actor, Meeting, Person)) if
%   -meeting_scheduled(Meeting),
%   higher_ranking_than(Person, Actor)
%   busy_working(Person)
-permitted(invite_to_meeting(Actor, Meeting, Person))  :-
    agent(Actor),
    -holds(meeting_scheduled(Meeting), timestep),
    holds(higher_ranking_than(Person, Actor), timestep),
    holds(busy_working(Person), timestep),
    not permitted(invite_to_meeting(Actor, Meeting, Person)).

% prefer(meeting_2, meeting_1)

% "Normally, no one is authorized to hold a meeting with more than two people outside of a conference room"
%
% normally permitted(hold_meeting(Actor, Meeting)) if
%   meeting_attendee_count(Meeting, AttendeeCount),
%   AttendeeCount > 2,
%   person_location(Actor, Location),
%   (not in conference room)

% "Normally, no one is allowed to hold an impromptu meeting"
%
% normally -permitted(hold_meeting(Actor, Meeting)) if
%   -meeting_scheduled(Meeting)

% "Normally, no one is allowed to hold a meeting with their supervisor unless they have first held a meeting with their co-workers"

% "Anyone is allowed to hold an impromptu meeting if it is urgent"
%
% permitted(hold_meeting(Actor, Meeting)) if
%   -meeting_scheduled(Meeting),
%   urgent_meeting(Meeting)

% "Classified meetings are not authorized outside of a classified room"

% "No one can enter a classified meeting or location when an electronic device"


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
