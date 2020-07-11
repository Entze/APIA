val(FluentName) | -val(FluentName) :-
    FluentName = (
        enrolled(Student, Class);
        meeting(Class, MeetingNum);
        due_date(meeting(Class, MeetingNum), assignment(Class, AssignmentNum));
        family_emergency(Student, meeting(Class, MeetingNum));
        religious_holiday(meeting(Class, MeetingNum))
    ),
    student(Student),
    class(Class),
    MeetingNum = 1..3,
    AssignmentNum = 1..3.
