% P.lp

% "Students are expected to not miss class"
-obl(attend(Student, meeting(Class, MeetingNum))) :-
    enrolled(Student, Class),
    not ab(d1(Student, Class, MeetingNum)),
    not obl(attend(Student, meeting(Class, MeetingNum)),
    % Supplementary atom to bind MeetingNum to value
    meeting(Class, MeetingNum).

% "Students do not need to attend class during family emergencies"
-obl(attend(Student, meeting(Class, MeetingNum))) :-
    family_emergency(Student, meeting(Class, MeetingNum)).

% "Students should not attend class on a religious holiday"
obl(-attend(Student, meeting(Class, MeetingNum)) :-
    religious_holiday(meeting(Class, MeetingNum)),
    not ab(d2(Student, Class, MeetingNum)),
    not -obl(-attend(Student, meeting(Class, MeetingNum))),
    % Supplementary atoms to bind Student and MeetingNum variables
    student(Student),
    meeting(Class, MeetingNum).

% "I would rather a student follow participate in religious holidays than attend class"
ab(d1(Student, Class, MeetingNum)) :-
    religious_holiday(meeting(Class, MeetingNum)),
    % Supplementary atoms to bind Student and MeetingNum variables
    student(Student).

% "Students should submit homework on time"
obl(submit(Student, assignment(Class, AssignmentNum))) :-
    enrolled(Student, Class),
    due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)),
    not ab(d3(Student, Class, AssignmentNum, MeetingNum)),
    not -obl(submit(Student, assignment(Class, AssignmentNum))).

% "Students should do their homework independently"
obl(-accept_unauthorized_help(Student)).
