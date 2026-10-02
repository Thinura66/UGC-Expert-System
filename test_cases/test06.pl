% test_cases/test06.pl
:- multifile test/5.
test(tc06, 'Foreign scholarship accepted', [foreign_scholarship-yes],
     ineligible(foreign_scholarship), [r13]).
