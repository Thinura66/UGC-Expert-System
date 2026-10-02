% test_cases/test05.pl
:- multifile test/5.
test(tc05, 'Previous UGC registration', [previous_ugc_registration-yes],
     ineligible(previous_ugc_registration), [r06]).
