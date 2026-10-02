%% =====================================================================
%%  FILE: explanation.pl
%%  Rule explanations, messages, reasoning output and final verdicts
%% =====================================================================

%% ---- One plain-English sentence per rule (matches the Source column) -
explanation(r01, 'All three approved subjects have S or above and attempts are 3 or fewer: basic requirement satisfied. [S1.2]').
explanation(r02, 'Common General Paper mark is 30% or above: CGP requirement satisfied. [S1.2]').
explanation(r03, 'Current CGP is below 30% but a previous qualifying attempt was 30% or above: that result may be considered. [S1.2]').
explanation(r04, 'Neither the current nor a previous CGP mark satisfies the requirement: cannot register for the selected course. [S1.2]').
explanation(r05, 'Sitting the A/L examination on more than three occasions makes a student ineligible. [S1.7]').
explanation(r06, 'A student previously registered as an internal State University student is ineligible. [S1.7]').
explanation(r07, 'A student registered for a specified free first degree is ineligible. [S1.7]').
explanation(r08, 'A student registered at a College of Education is ineligible. [S1.7]').
explanation(r09, 'A student registered for a qualifying University College diploma is ineligible. [S1.7]').
explanation(r10, 'A student registered for HND/NDES for 3 years or more is normally ineligible. [S1.7]').
explanation(r11, 'A qualifying HND/NDES student who withdrew within 60 days is exempt from that ineligibility. [S1.7]').
explanation(r12, 'An HND/NDES student who entered by filling a vacancy does not get the 60-day concession. [S1.7]').
explanation(r13, 'A student who accepted a qualifying foreign scholarship is ineligible. [S1.7]').
explanation(r14, 'A student who already obtained the relevant first degree is ineligible. [S1.7]').
explanation(r15, 'A false declaration or forged documents make the student ineligible. [S1.7]').
explanation(r16, 'Fee paid, online registration completed before the deadline, and (payment was online, or payment was by bank with a voucher): registration valid. [S1.6]').
explanation(r17, 'Paying the fee WITHOUT completing online registration makes the registration invalid. [S1.6]').
explanation(r18, 'A bank payment requires a paying-in voucher. [S1.6]').
explanation(r19, 'A maximum of 125 Uni-Code choices may be entered. [S3.1]').
explanation(r20, 'The selected course prerequisites are not satisfied: the course is not eligible. [S2.2]').
explanation(r21, 'The same Uni-Code cannot be entered more than once. [S3.1]').
explanation(r22, 'A course not included in the preference list cannot be considered. [S3.1]').
explanation(r23, 'When the first preference cannot be selected, the next eligible preference is considered. [S3.2]').
explanation(r24, 'A candidate eligible for the course has their Z-score and preference order considered. [S3.2]').
explanation(r25, 'If a student does not register for the selected Uni-Code, vacancy consideration follows the handbook procedure. [S3.1]').

conclusion_message(basic_requirement_satisfied,       'Basic A/L requirement satisfied').
conclusion_message(cgp_requirement_satisfied,          'CGP requirement satisfied').
conclusion_message(previous_result_may_be_considered,  'Previous qualifying CGP result may be considered').
conclusion_message(cannot_register_selected_course,    'Cannot register for the selected course (CGP requirement not met)').
conclusion_message(hnd_exception_applies,              '60-day HND/NDES withdrawal exception applies').
conclusion_message(concession_not_applicable,          'HND/NDES 60-day concession does not apply (entered via vacancy)').
conclusion_message(registration_valid,                 'Registration requirements satisfied').
conclusion_message(invalid_registration,               'INVALID REGISTRATION (fee paid but online registration not completed)').
conclusion_message(voucher_required,                   'Paying-in voucher required for bank payment').
conclusion_message(course_not_eligible(prerequisites_not_met), 'Course NOT eligible - prerequisites not met').
conclusion_message(course_cannot_be_considered,        'Course cannot be considered - not in preference list').
conclusion_message(consider_next_preference,           'First preference unavailable - next eligible preference is considered').
conclusion_message(zscore_and_preference_considered,   'Eligible for the course - Z-score and preference order are considered').
conclusion_message(vacancy_procedure_follows_handbook, 'Student did not register for the Uni-Code - vacancy procedure follows the handbook').
conclusion_message(eligible_for_registration,          'ELIGIBLE FOR REGISTRATION (final decision)').
conclusion_message(ineligible(Why), Text) :-
    format(atom(Text), 'INELIGIBLE (~w)', [Why]).
conclusion_message(invalid_preference_list(Why), Text) :-
    format(atom(Text), 'INVALID PREFERENCE LIST (~w)', [Why]).

%% ---- Describing a condition for the explanation trace -----------------
describe_cond(eq(A,V))     :- ( known(A,X) -> format('~w = ~w  (required: ~w)', [A,X,V]) ; format('~w unknown', [A]) ).
describe_cond(cmp(A,Op,V)) :- ( known(A,X) -> format('~w = ~w  ->  test ~w ~w ~w', [A,X,X,Op,V]) ; format('~w unknown', [A]) ).
describe_cond(in(A,L))     :- ( known(A,X) -> format('~w = ~w  (must be one of ~w)', [A,X,L]) ; format('~w unknown', [A]) ).
describe_cond(derived(C))  :- format('~w has been concluded', [C]).
describe_cond(no(C))       :- functor(C, F, _), format('no "~w" conclusion has been reached', [F]).
describe_cond(or(A,B))     :- write('either ('), describe_cond(A), write(')  OR  ('), describe_cond(B), write(')').

explain_fired :-
    writeln('--- RULES FIRED AND WHY ---'),
    (   fired(_,_)
    ->  forall(fired(Id, Head),
           (   ( Id == final
               -> nl, writeln('[FINAL DECISION] Combines R01-R04, R05-R15 and R16-R18.'),
                  writeln('  Because: basic requirement, CGP requirement (or previous result), no ineligibility, and a valid registration were all established above.')
               ;  upcase_atom(Id, U),
                  format('~n[~w FIRED] ', [U]),
                  ( explanation(Id, T) -> writeln(T) ; nl ),
                  writeln('  Because:'),
                  rule(Id, _, Conds, _),
                  forall(member(C, Conds),
                         ( write('    - '), describe_cond(C), nl ))
               ),
               ( conclusion_message(Head, M) -> true ; M = Head ),
               format('  Conclusion: ~w~n', [M])
           ))
    ;   writeln('  No rule fired.')
    ).

%% ---- Verdicts per menu mode -------------------------------------------
verdict(admission, V) :-
    (   derived(ineligible(_))                 -> V = 'INELIGIBLE'
    ;   derived(cannot_register_selected_course) -> V = 'CANNOT REGISTER FOR SELECTED COURSE - CGP NOT MET'
    ;   derived(basic_requirement_satisfied),
        ( derived(cgp_requirement_satisfied) ; derived(previous_result_may_be_considered) )
    ->  V = 'ADMISSION REQUIREMENTS SATISFIED'
    ;   V = 'ADMISSION REQUIREMENTS NOT SATISFIED'
    ).

verdict(registration, V) :-
    (   derived(invalid_registration)  -> V = 'INVALID REGISTRATION'
    ;   derived(registration_valid)    -> V = 'REGISTRATION VALID'
    ;   derived(voucher_required)      -> V = 'REGISTRATION INCOMPLETE - PAYING-IN VOUCHER REQUIRED'
    ;   V = 'REGISTRATION INCOMPLETE / NOT VALID'
    ).

verdict(course, V) :-
    (   derived(course_not_eligible(_))            -> V = 'COURSE NOT ELIGIBLE (prerequisites not met)'
    ;   derived(course_cannot_be_considered)        -> V = 'COURSE CANNOT BE CONSIDERED (not in preference list)'
    ;   derived(zscore_and_preference_considered)   -> V = 'ELIGIBLE - Z-SCORE AND PREFERENCE ORDER CONSIDERED'
    ;   V = 'COURSE STATUS UNDETERMINED'
    ).

verdict(unicode, V) :-
    (   derived(invalid_preference_list(_)) -> V = 'INVALID PREFERENCE LIST'
    ;   V = 'PREFERENCE LIST VALID'
    ).

verdict(full, V) :-
    (   derived(ineligible(_))                 -> V = 'INELIGIBLE'
    ;   derived(invalid_registration)          -> V = 'INVALID REGISTRATION'
    ;   derived(cannot_register_selected_course)-> V = 'CANNOT REGISTER FOR SELECTED COURSE - CGP NOT MET'
    ;   derived(course_not_eligible(_))         -> V = 'COURSE NOT ELIGIBLE'
    ;   derived(invalid_preference_list(_))     -> V = 'INVALID PREFERENCE LIST'
    ;   derived(voucher_required),
        \+ derived(registration_valid)         -> V = 'REGISTRATION INCOMPLETE - PAYING-IN VOUCHER REQUIRED'
    ;   derived(eligible_for_registration)      -> V = 'ELIGIBLE FOR REGISTRATION'
    ;   V = 'NOT ELIGIBLE / CONDITIONS NOT MET'
    ).

print_result(Mode) :-
    verdict(Mode, V),
    nl, writeln('============================================='),
    writeln('                  RESULT'),
    writeln('============================================='),
    format('STATUS: ~w~n~n', [V]),
    write('Rules Applied: '),
    findall(U, (fired(Id,_), ( Id == final -> U = 'FINAL' ; upcase_atom(Id,U) )), Us),
    ( Us == [] -> writeln('none') ; atomic_list_concat(Us, ', ', S), writeln(S) ),
    nl, writeln('Findings:'),
    forall(derived(D),
           ( conclusion_message(D, M) -> format('  * ~w~n', [M]) ; format('  * ~w~n', [D]) )),
    writeln('=============================================').
