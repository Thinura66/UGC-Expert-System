% test_cases/test09.pl
:- multifile test/5.
test(tc09, 'More than 125 Uni-Codes', [unicode_count-130],
     invalid_preference_list(too_many_unicodes), [r19]).
