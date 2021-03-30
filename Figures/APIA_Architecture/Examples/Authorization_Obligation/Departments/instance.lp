%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person(Person) :-
    Person = (
        "Bob";
        "Alice"
    ).

agent(Person) :-
    person(Person),
    Person = "Bob".

employee(Person) :-
    person(Person),
    Person = "Bob".

% department(Department) :-
%     Department = 1.
%
% department(Person, Department) :-
%     employee(Person),
%     department(Department),
%     Department = 1.
%
% supervisor_to(Boss, Person) :-
%     person(Boss),
%     person(Person),
%     Boss = 1,
%     Person = 2.
