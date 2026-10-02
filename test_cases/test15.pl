% test_cases/test15.pl
:- multifile test/5.
test(tc15, 'Course prerequisites not satisfied', [course_prerequisites_satisfied-no],
     course_not_eligible(prerequisites_not_met), [r20]).
