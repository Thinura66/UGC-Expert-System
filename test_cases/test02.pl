% test_cases/test02.pl
:- multifile test/5.
test(tc02, 'More than 3 A/L attempts', [attempt_count-4],
     ineligible(more_than_three_attempts), [r05]).