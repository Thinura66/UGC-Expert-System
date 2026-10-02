% test_cases/test17.pl
:- multifile test/5.
test(tc17, 'First preference unavailable', [first_preference_available-no],
     consider_next_preference, [r23]).
