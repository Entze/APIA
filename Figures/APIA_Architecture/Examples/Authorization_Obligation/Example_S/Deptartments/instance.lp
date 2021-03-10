%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Statics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

person(Person) :-
    Person = (1; 2).

agent(Person) :-
    person(Person),
    Person = 1.

employee(Person) :-
    person(Person),
    Person = 1.

department(Department) :-
    Department = 1.

department(Person, Department) :-
    employee(Person),
    department(Department),
    Department = 1.

supervisor_to(Boss, Person) :-
    person(Boss),
    person(Person),
    Boss = 1,
    Person = 2.

higher_ranking_than(Boss, Person) :-
    supervisor_to(Boss, Person).

higher_ranking_than(HigherPerson, LowerPerson) :-
    higher_ranking_than(HigherPerson, MidPerson)
    supervisor_to(MidPerson, LowerPerson).
