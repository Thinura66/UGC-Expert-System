%% =====================================================================
%%  FILE: facts.pl
%%  Fact storage (dynamic predicates) and default facts used by the tests
%% =====================================================================

:- dynamic known/2.       % known(Attribute, Value)     -- student facts
:- dynamic derived/1.     % derived(Conclusion)         -- forward chaining results
:- dynamic fired/2.       % fired(RuleId, Conclusion)   -- rules that fired (in order)
:- dynamic last_mode/1.   % remembers what the user last checked

put_fact(A, V)  :- retractall(known(A,_)), assertz(known(A,V)).
reset_facts     :- retractall(known(_,_)), retractall(derived(_)), retractall(fired(_,_)).

%% ---------------------------------------------------------------------
%% The 28 facts/attributes used by this system (assignment requires 20+)
%%
%%  Academic (R01-R05)
%%    attempt_count, subject1_grade, subject2_grade, subject3_grade,
%%    cgp_mark, previous_cgp_mark
%%
%%  Ineligibility conditions (R06-R15)
%%    previous_ugc_registration, previous_first_degree, college_of_education,
%%    university_college_diploma, hnd_ndes_registration,
%%    hnd_ndes_duration_years, hnd_ndes_withdrawn, withdrawal_within_60_days,
%%    hnd_ndes_entered_via_vacancy, foreign_scholarship, previous_degree,
%%    false_declaration
%%
%%  Registration (R16-R18)
%%    ugc_selected, registration_fee_paid, online_registration,
%%    registration_before_deadline, payment_method, voucher_uploaded
%%
%%  Uni-Code / preferences / course (R19-R25)
%%    unicode_count, duplicate_unicode, course_prerequisites_satisfied,
%%    course_in_preference_list, first_preference_available,
%%    registered_for_unicode
%% ---------------------------------------------------------------------

% Default facts = a normal, fully-eligible student.
% The test cases start from this set and override only what they need to test.
default_facts([
    attempt_count-2, subject1_grade-a, subject2_grade-b, subject3_grade-c,
    cgp_mark-65, previous_cgp_mark-0,

    previous_ugc_registration-no, previous_first_degree-no,
    college_of_education-no, university_college_diploma-no,
    hnd_ndes_registration-no, hnd_ndes_duration_years-0,
    hnd_ndes_withdrawn-no, withdrawal_within_60_days-no,
    hnd_ndes_entered_via_vacancy-no,
    foreign_scholarship-no, previous_degree-no, false_declaration-no,

    ugc_selected-yes, registration_fee_paid-yes, online_registration-yes,
    registration_before_deadline-yes, payment_method-online,
    voucher_uploaded-not_required,

    unicode_count-20, duplicate_unicode-no,
    course_prerequisites_satisfied-yes, course_in_preference_list-yes,
    first_preference_available-yes, registered_for_unicode-yes
]).
