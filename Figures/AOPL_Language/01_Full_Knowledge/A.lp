% All students attend the classes in which they are enrolled on day 1
occurs(attend(Student, meeting(Class, MeetingNum))) :-
    student(Student),
    enrolled(Student, Class),
    MeetingNum = 1.

% All students submit the assignments for the classes in which they are enrolled on day 1
occurs(submit(Student, assignment(Class, AssignmentNum), meeting(Class, MeetingNum))) :-
    student(Student),
    enrolled(Student, Class),
    meeting(Class, MeetingNum),
    due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)),
    MeetingNum = 1.

% Jill and Bob do not attend any classes on day 2
-occurs(attend(Student, meeting(Class, MeetingNum))) :-
    Student = ("Jill"; "Bob"),
    class(Class),
    MeetingNum = 2.

% Jack attends all of his enrolled classes on day 2
occurs(attend(Student, meeting(Class, MeetingNum))) :-
    Student = "Jack",
    enrolled(Student, Class),
    MeetingNum = 2.

% All students submit the assignments for the classes in which they are enrolled on day 2
occurs(submit(Student, assignment(Class, AssignmentNum), meeting(Class, MeetingNum))) :-
    student(Student),
    enrolled(Student, Class),
    meeting(Class, MeetingNum),
    due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)),
    MeetingNum = 2.
