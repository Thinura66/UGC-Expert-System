% test_cases/test07.pl
:- multifile test/5.
test(tc07, 'Fee paid but online registration not completed', [online_registration-no],
     invalid_registration, [r17]).
