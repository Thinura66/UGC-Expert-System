%% =====================================================================
%%  FILE: main.pl
%%  Entry point: loads all files and provides the CLI menu
%% =====================================================================

:- use_module(library(readutil)).
:- use_module(library(lists)).

% ---- Load the other files (paths are relative to this file) ----------
:- consult('facts.pl').
:- consult('rules.pl').
:- consult('forward.pl').
:- consult('inference.pl').
:- consult('explanation.pl').
:- consult('test_cases/test01.pl').
:- consult('test_cases/test02.pl').
:- consult('test_cases/test03.pl').
:- consult('test_cases/test04.pl').
:- consult('test_cases/test05.pl').
:- consult('test_cases/test06.pl').
:- consult('test_cases/test07.pl').
:- consult('test_cases/test08.pl').
:- consult('test_cases/test09.pl').
:- consult('test_cases/test10.pl').
:- consult('test_cases/test11.pl').
:- consult('test_cases/test12.pl').
:- consult('test_cases/test13.pl').
:- consult('test_cases/test14.pl').
:- consult('test_cases/test15.pl').
:- consult('test_cases/test16.pl').
:- consult('test_cases/test17.pl').
:- consult('test_cases/test18.pl').
:- consult('test_cases/test19.pl').
:- consult('test_cases/test_runner.pl').

%% =====================================================================
%%  INPUT HELPERS
%% =====================================================================
prompt_line(Prompt, S) :-
    write(Prompt), flush_output(user_output),
    read_line_to_string(user_input, L),
    ( L == end_of_file -> nl, halt ; true ),
    normalize_space(string(S0), L),
    string_lower(S0, S).

ask_int(Prompt, Min, Max, N) :-
    repeat,
    prompt_line(Prompt, S),
    (   number_string(N0, S), integer(N0), N0 >= Min, N0 =< Max
    ->  N = N0
    ;   format('  Please enter a whole number between ~w and ~w.~n', [Min,Max]), fail
    ), !.

ask_yn(Prompt, V) :-
    string_concat(Prompt, ' (yes/no): ', P),
    repeat,
    prompt_line(P, S),
    (   member(S, ["yes","y"]) -> V = yes
    ;   member(S, ["no","n"])  -> V = no
    ;   writeln('  Please answer yes or no.'), fail
    ), !.

ask_grade(Prompt, G) :-
    repeat,
    prompt_line(Prompt, S),
    (   member(S, ["a","b","c","s","f"]) -> atom_string(G, S)
    ;   writeln('  Please enter A, B, C, S or F.'), fail
    ), !.

ask_fact(A, Q)  :- ask_yn(Q, V), put_fact(A, V).

%% =====================================================================
%%  DATA COLLECTION (one block per menu option)
%% =====================================================================
collect_admission :-
    nl, writeln('--- A/L RESULTS ---'),
    ask_int('Number of A/L attempts (1-10): ', 1, 10, N), put_fact(attempt_count, N),
    forall(between(1,3,I),
           ( format(atom(P), 'Grade for approved subject ~w (A/B/C/S/F): ', [I]),
             ask_grade(P, G),
             format(atom(K), 'subject~w_grade', [I]),
             put_fact(K, G) )),
    ask_int('Common General Paper mark (0-100): ', 0, 100, M), put_fact(cgp_mark, M),
    (   M < 30
    ->  ask_int('Previous CGP mark (0 if none): ', 0, 100, PM), put_fact(previous_cgp_mark, PM)
    ;   put_fact(previous_cgp_mark, 0) ),
    nl, writeln('--- PREVIOUS STUDY / QUALIFICATIONS ---'),
    ask_fact(previous_ugc_registration,  'Previously registered as an internal State University student?'),
    ask_fact(previous_first_degree,      'Registered for a specified free first degree?'),
    ask_fact(college_of_education,       'Registered at a College of Education?'),
    ask_fact(university_college_diploma, 'Registered for a qualifying University College diploma?'),
    ask_fact(hnd_ndes_registration,      'Registered for an HND/NDES programme?'),
    (   known(hnd_ndes_registration, yes)
    ->  ask_int('How many years registered for HND/NDES (0-10)?: ', 0, 10, Y), put_fact(hnd_ndes_duration_years, Y),
        ask_fact(hnd_ndes_withdrawn, 'Did you withdraw from the HND/NDES programme?'),
        (   known(hnd_ndes_withdrawn, yes)
        ->  ask_fact(withdrawal_within_60_days, 'Was the withdrawal within 60 days?')
        ;   put_fact(withdrawal_within_60_days, no) ),
        ask_fact(hnd_ndes_entered_via_vacancy, 'Did you enter the HND/NDES programme by filling a vacancy?')
    ;   put_fact(hnd_ndes_duration_years, 0),
        put_fact(withdrawal_within_60_days, no),
        put_fact(hnd_ndes_entered_via_vacancy, no) ),
    ask_fact(foreign_scholarship, 'Accepted a qualifying foreign scholarship?'),
    ask_fact(previous_degree,     'Already obtained the relevant first degree?'),
    ask_fact(false_declaration,   'Any false declaration / forged documents?').

collect_registration :-
    nl, writeln('--- REGISTRATION ---'),
    ask_fact(ugc_selected,                'Selected by the UGC?'),
    ask_fact(registration_fee_paid,       'Registration fee (Rs. 50) paid?'),
    ask_fact(online_registration,         'Online registration completed?'),
    ask_fact(registration_before_deadline,'Registration completed before the deadline?'),
    repeat,
      prompt_line('Payment method (online/bank): ', S),
      ( member(S, ["online","bank"]) -> atom_string(PM, S) ; writeln('  Enter online or bank.'), fail ), !,
    put_fact(payment_method, PM),
    (   PM == bank
    ->  ask_fact(voucher_uploaded, 'Paying-in voucher uploaded?')
    ;   put_fact(voucher_uploaded, not_required) ).

collect_course :-
    nl, writeln('--- COURSE & PREFERENCE (UNI-CODE) CHECKS ---'),
    ask_fact(course_prerequisites_satisfied, 'Are the prerequisites for the selected course satisfied?'),
    ask_fact(course_in_preference_list,      'Is this course included in your Uni-Code preference list?'),
    ask_fact(first_preference_available,     'Is your first-preference course available for selection?'),
    ask_int('Number of Uni-Codes entered (0-300): ', 0, 300, N), put_fact(unicode_count, N),
    ask_fact(duplicate_unicode,              'Is any Uni-Code entered more than once?'),
    ask_fact(registered_for_unicode,         'Did you register for the Uni-Code you were selected for?').

run_mode(Mode) :-
    retractall(last_mode(_)), assertz(last_mode(Mode)),
    forward_chain(false),
    print_result(Mode),
    explain_fired,
    nl, writeln('(Choose option 6 to see the full forward + backward chaining traces.)').

view_reasoning :-
    (   known(_,_)
    ->  nl, forward_chain(true), nl,
        explain_fired, nl,
        backward_report
    ;   writeln('No facts yet - run a check first (options 1-4).')
    ).

%% =====================================================================
%%  MENU
%% =====================================================================
banner :-
    nl,
    writeln('============================================='),
    writeln(' UGC UNIVERSITY ADMISSION EXPERT SYSTEM'),
    writeln('          Academic Year 2025/2026'),
    writeln('============================================='), nl,
    writeln('1. Check Admission Eligibility'),
    writeln('2. Check Registration'),
    writeln('3. Check Course & Uni-Code Preferences'),
    writeln('4. Full Check (all of the above)'),
    writeln('5. Full Check (all of the above) + reasoning shown automatically'),
    writeln('6. View Reasoning (forward + backward chaining) for the last check'),
    writeln('7. Run Test Cases'),
    writeln('8. Exit'), nl.

main :- repeat, banner, ask_int('Enter your choice: ', 1, 8, C), handle(C), C == 8, !.

handle(1) :- reset_facts, collect_admission,    run_mode(admission).
handle(2) :- reset_facts, collect_registration, run_mode(registration).
handle(3) :- reset_facts, collect_course,       run_mode(course).
handle(4) :- reset_facts, collect_admission, collect_registration, collect_course, run_mode(full).
handle(5) :- reset_facts, collect_admission, collect_registration, collect_course, run_mode(full), nl, view_reasoning.
handle(6) :- view_reasoning.
handle(7) :- run_tests.
handle(8) :- writeln('Goodbye.').
