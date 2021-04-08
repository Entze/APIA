%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Domains %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person(Person) :-
    Person = (
        "Alice";
        "Bob"
    ).

agent(Person) :-
    person(Person),
    Person = "Alice".

% employee(Person) :-
%     person(Person),
%     Person = "Alice".

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
