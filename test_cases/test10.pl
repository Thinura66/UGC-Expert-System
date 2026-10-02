% test_cases/test10.pl
:- multifile test/5.
test(tc10, 'Duplicate Uni-Code', [duplicate_unicode-yes],
     invalid_preference_list(duplicate_unicode), [r21]).
