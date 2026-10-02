% test_cases/test11.pl
:- multifile test/5.
test(tc11, 'HND/NDES 3+ years, no withdrawal',
     [hnd_ndes_registration-yes, hnd_ndes_duration_years-3, hnd_ndes_withdrawn-no],
     ineligible(hnd_ndes_registration), [r10]).
