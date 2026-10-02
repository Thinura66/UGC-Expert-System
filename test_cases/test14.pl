% test_cases/test14.pl
% Same as tc13, but the student entered by filling a vacancy, so R12
% removes the concession and R10 still makes the student ineligible.
:- multifile test/5.
test(tc14, 'HND/NDES vacancy entry removes the 60-day concession',
     [hnd_ndes_registration-yes, hnd_ndes_duration_years-3,
      hnd_ndes_withdrawn-yes, withdrawal_within_60_days-yes,
      hnd_ndes_entered_via_vacancy-yes],
     ineligible(hnd_ndes_registration), [r12,r10]).
