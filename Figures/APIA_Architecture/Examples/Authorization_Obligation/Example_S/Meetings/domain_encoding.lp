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

% meeting_held(Meeting)
fluent(inertial, meeting_held(Meeting)) :-
    meeting(Meeting).

% impromptu_meeting(Meeting)
fluent(defined, impromptu_meeting(Meeting)) :-
    meeting(Meeting).

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

% stop_working(Actor)

% schedule_meeting(Actor, Meeting)

% classify_meeting(Actor, Meeting)

% invite_to_meeting(Actor, Meeting, Person)

% hold_meeting(Actor, Meeting)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Action descriptions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% -----------------------------------------------------------------------

% begin_working(Actor)
%   causes busy_working(Actor)

% -----------------------------------------------------------------------

% stop_working(Actor)
%   causes -busy_working(Actor)

% -----------------------------------------------------------------------

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

% -----------------------------------------------------------------------

% classify_meeting(Actor, Meeting)
%   causes meeting_classified(Meeting)

% -----------------------------------------------------------------------

% invite_to_meeting(Actor, Meeting, Person)
%   causes meeting_attendee(Meeting, Person)

% -----------------------------------------------------------------------

% hold_meeting(Actor, Meeting)
%   causes meeting_held(Meeting)

% impromptu_meeting(Meeting) if
%   meeting_held(Meeting),
%   -meeting_scheduled(Meeting)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AOPL Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program action_description(timestep).

% "Normally, no one is allowed to hold a meeting until all attendees are present"

% "Normally, anyone is allowed to hold an impromptu meeting with a coworker if the coworker is not busy"

% "Normally, no one is allowed to hold an impromptu meeting with a coworker if he is busy"

% "Normally, no one is allowed to hold an impromptu meeting with a higher-ranking employee if he is busy"

% "Normally, no one is authorized to hold a meeting with more than two people outside of a conference room"

% "Normally, no one is allowed to hold a meeting without first scheduling it"

% "Normally, no one is allowed to hold a meeting with their supervisor unless they have first held a meeting with their co-workers"

% "Anyone is allowed to hold an impromptu meeting if it is urgent"

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
