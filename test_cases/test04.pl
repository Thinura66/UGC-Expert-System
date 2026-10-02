% test_cases/test04.pl
:- multifile test/5.
test(tc04, 'CGP below 30, previous CGP also below 30', [cgp_mark-20, previous_cgp_mark-25],
     cannot_register_selected_course, [r04]).