% s0.lp

% All students are enrolled in all classes
enrolled(Student, Class) :-
    student(Student),
    class(Class).

% The English class has two class meetings
meeting(Class, MeetingNum) :-
    Class = "English",
    MeetingNum = 1..2.

% The English class has three assignments
assignment(Class, AssignmentNum) :-
    Class = "English",
    AssignmentNum = 1..3.

% The first English assignment is due on the second day of class
due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)) :-
    Class = "English",
    AssignmentNum = 1,
    MeetingNum = 1.

% The second and third English assignments are due on the second day of class
due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)) :-
    Class = "English",
    AssignmentNum = (2; 3),
    MeetingNum = 2.

% The Math class has three class meetings
meeting(Class, MeetingNum) :-
    Class = "Math",
    MeetingNum = 1..3.

% The Math class has two assignments
assignment(Class, AssignmentNum) :-
    Class = "Math",
    AssignmentNum = 1..2.

% The both Math assignments are due on the third day of class
due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum)) :-
    Class = "Math",
    AssignmentNum = (1; 2),
    MeetingNum = 3.

% There is a religious holiday on the third day of school that affects all classes
religious_holiday(meeting(Class, MeetingNum)) :-
    meeting(Class, MeetingNum),
    MeetingNum = 3.

% A student named Jill, if she exists, has a family emergency that infers with all classes occuring on the second day of school
family_emergency(Student, meeting(Class, MeetingNum)) :-
    student(Student),
    meeting(Class, MeetingNum),
    Student = "Jill",
    MeetingNum = 2.
