% test_cases/test13.pl
% Withdrew within 60 days, NOT via vacancy: the exception applies,
% so ineligible(hnd_ndes_registration) must NOT fire.
:- multifile test/5.
test(tc13, 'HND/NDES 60-day withdrawal exception applies',
     [hnd_ndes_registration-yes, hnd_ndes_duration_years-3,
      hnd_ndes_withdrawn-yes, withdrawal_within_60_days-yes,
      hnd_ndes_entered_via_vacancy-no],
     hnd_exception_applies, [r11]).
