% test_cases/test12.pl
:- multifile test/5.
test(tc12, 'False declaration / forged documents', [false_declaration-yes],
     ineligible(false_declaration), [r15]).
