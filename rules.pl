%% =====================================================================
%%  FILE: rules.pl
%%  The rule base: rule(Id, Stratum, Conditions, Conclusion)
%%
%%  This matches the Rule Specification Table exactly (R01-R25).
%%  "Source" column (handbook section) is kept as a comment on each rule.
%%
%%  Condition types (tested by test_base/1, fw_cond/1, prove_cond/2):
%%    eq(Attr, Value)        fact Attr has exactly Value
%%    cmp(Attr, Op, Number)  numeric comparison  (>, <, >=, =<)
%%    in(Attr, List)         fact value is a member of List
%%    or(CondA, CondB)       either condition holds
%%    derived(Concl)         another rule has already concluded Concl
%%    no(Concl)              Concl can NOT be concluded (negation as failure)
%%
%%  Stratum = evaluation order for forward chaining (1 first ... 4 last),
%%  so a rule using no(...)/derived(...) only runs after the rule(s) that
%%  could produce what it depends on.
%% =====================================================================

% ---- R01-R04 : Academic / CGP requirement  (Handbook S1.2) -----------

% R01  If all three approved subjects have >= S and attempts <= 3
%      -> basic requirement satisfied
rule(r01, 1, [in(subject1_grade,[a,b,c,s]),
              in(subject2_grade,[a,b,c,s]),
              in(subject3_grade,[a,b,c,s]),
              cmp(attempt_count,=<,3)],           basic_requirement_satisfied).

% R02  If CGP >= 30% -> CGP requirement satisfied
rule(r02, 1, [cmp(cgp_mark,>=,30)],                cgp_requirement_satisfied).

% R03  If current CGP < 30% but a previous qualifying attempt >= 30%
%      -> previous result may be considered
rule(r03, 1, [cmp(cgp_mark,<,30),
              cmp(previous_cgp_mark,>=,30)],       previous_result_may_be_considered).

% R04  If the CGP requirement is not satisfied (by R02 or R03)
%      -> candidate cannot register for the selected course
rule(r04, 2, [no(cgp_requirement_satisfied),
              no(previous_result_may_be_considered)], cannot_register_selected_course).

% ---- R05-R15 : Ineligibility conditions  (Handbook S1.7) -------------

% R05  If A/L attempts > 3 -> ineligible
rule(r05, 1, [cmp(attempt_count,>,3)],             ineligible(more_than_three_attempts)).

% R06  If previously registered as an internal State University student
%      -> ineligible
rule(r06, 1, [eq(previous_ugc_registration,yes)],  ineligible(previous_ugc_registration)).

% R07  If registered for a specified free first degree -> ineligible
rule(r07, 1, [eq(previous_first_degree,yes)],      ineligible(previous_first_degree)).

% R08  If registered at a College of Education -> ineligible
rule(r08, 1, [eq(college_of_education,yes)],       ineligible(college_of_education)).

% R09  If registered for a qualifying University College diploma
%      -> ineligible
rule(r09, 1, [eq(university_college_diploma,yes)], ineligible(university_college_diploma)).

% R10  If registered for HND/NDES for 3 years or more -> normally ineligible
%      (unless the R11 exception applies)
rule(r10, 3, [eq(hnd_ndes_registration,yes),
              cmp(hnd_ndes_duration_years,>=,3),
              no(hnd_exception_applies)],          ineligible(hnd_ndes_registration)).

% R11  If a qualifying HND/NDES student withdrew within 60 days
%      -> the exception applies (unless R12 removes the concession)
rule(r11, 2, [eq(hnd_ndes_withdrawn,yes),
              eq(withdrawal_within_60_days,yes),
              no(concession_not_applicable)],      hnd_exception_applies).

% R12  If the HND/NDES student entered by filling a vacancy
%      -> the 60-day concession does not apply
rule(r12, 1, [eq(hnd_ndes_entered_via_vacancy,yes)], concession_not_applicable).

% R13  If a qualifying foreign scholarship was accepted -> ineligible
rule(r13, 1, [eq(foreign_scholarship,yes)],        ineligible(foreign_scholarship)).

% R14  If the relevant first degree has already been obtained -> ineligible
rule(r14, 1, [eq(previous_degree,yes)],            ineligible(previous_degree)).

% R15  If a false declaration or forged documents are found -> ineligible
rule(r15, 1, [eq(false_declaration,yes)],          ineligible(false_declaration)).

% ---- R16-R18 : Registration  (Handbook S1.6) -------------------------

% R16  If fee paid + online registration completed before the deadline,
%      and (payment was online, OR payment was by bank WITH voucher)
%      -> registration valid
rule(r16, 1, [eq(registration_fee_paid,yes),
              eq(online_registration,yes),
              eq(registration_before_deadline,yes),
              or(eq(payment_method,online),
                 eq(voucher_uploaded,yes))],       registration_valid).

% R17  If fee paid but online registration not completed
%      -> registration invalid
rule(r17, 1, [eq(registration_fee_paid,yes),
              eq(online_registration,no)],         invalid_registration).

% R18  If a bank payment was used -> a paying-in voucher is required
rule(r18, 1, [eq(payment_method,bank)],            voucher_required).

% ---- R19, R21 : Uni-Code preference list  (Handbook S3.1) ------------

% R19  If Uni-Code choices > 125 -> invalid preference list
rule(r19, 1, [cmp(unicode_count,>,125)],           invalid_preference_list(too_many_unicodes)).

% R21  If the same Uni-Code appears twice -> invalid preference list
rule(r21, 1, [eq(duplicate_unicode,yes)],          invalid_preference_list(duplicate_unicode)).

% ---- R20, R22-R25 : Course eligibility & preferences  (Handbook S2.2, S3.1-3.2) --

% R20  If the selected course's prerequisites are not satisfied
%      -> course not eligible
rule(r20, 1, [eq(course_prerequisites_satisfied,no)], course_not_eligible(prerequisites_not_met)).

% R22  If the course is not included in the preferences
%      -> it cannot be considered
rule(r22, 1, [eq(course_in_preference_list,no)],   course_cannot_be_considered).

% R23  If the first preference cannot be selected
%      -> consider the next eligible preference
rule(r23, 1, [eq(first_preference_available,no)],  consider_next_preference).

% R24  If the candidate is eligible for the course
%      -> Z-score and preference order are considered
rule(r24, 4, [eq(course_prerequisites_satisfied,yes),
              no(course_cannot_be_considered),
              no(ineligible(_))],                  zscore_and_preference_considered).

% R25  If the student does not register for the selected Uni-Code
%      -> subsequent vacancy consideration follows the handbook procedure
rule(r25, 1, [eq(registered_for_unicode,no)],      vacancy_procedure_follows_handbook).
