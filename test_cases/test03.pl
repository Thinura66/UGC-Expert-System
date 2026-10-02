% test_cases/test03.pl
:- multifile test/5.
test(tc03, 'CGP below 30, previous CGP qualifies', [cgp_mark-25, previous_cgp_mark-45],
     previous_result_may_be_considered, [r03]).