%% =====================================================================
%%  FILE: forward.pl
%%  Forward chaining engine (facts -> conclusions)
%%
%%  Fires any rule whose conditions currently hold, adds its conclusion
%%  to working memory (derived/1), and repeats until nothing new fires.
%%  Strata (1..4) make sure a rule that depends on another rule's
%%  conclusion (via derived/1 or no/1) is only checked after that rule
%%  has had a chance to fire.
%% =====================================================================

fw_cond(derived(C))  :- derived(C).
fw_cond(no(C))       :- \+ derived(C).
fw_cond(or(A,B))      :- ( fw_cond(A) ; fw_cond(B) ).
fw_cond(C)            :- test_base(C).

forward_chain(Verbose) :-
    retractall(derived(_)),
    retractall(fired(_,_)),
    flag(fw_step, _, 1),
    ( Verbose == true
    -> writeln('--- FORWARD CHAINING TRACE ---'),
       forall(known(A,V), format('  Initial fact: ~w = ~w~n', [A,V]))
    ; true ),
    forall(member(S,[1,2,3,4]), fw_fixpoint(S, Verbose)),
    check_final_decision(Verbose),
    ( Verbose == true -> writeln('  (no more rules can fire)') ; true ).

fw_fixpoint(Stratum, Verbose) :-
    (   rule(Id, Stratum, Conds, Head),
        \+ fired(Id, _),
        forall(member(C, Conds), fw_cond(C))
    ->  assertz(fired(Id, Head)),
        ( derived(Head) -> true ; assertz(derived(Head)) ),
        flag(fw_step, N, N+1),
        ( Verbose == true
        -> upcase_atom(Id, U),
           format('  Step ~w: ~w fires  ==>  ~w~n', [N, U, Head])
        ; true ),
        fw_fixpoint(Stratum, Verbose)
    ;   true
    ).

%% ---------------------------------------------------------------------
%% FINAL DECISION: not a single numbered rule in the specification table,
%% because "eligible for registration" is the combination of the academic
%% rules (R01-R04), every ineligibility rule (R05-R15) and the
%% registration rules (R16-R18). It is computed once forward chaining has
%% reached a fixpoint, and is shown in traces/reports as "FINAL".
%% ---------------------------------------------------------------------
final_decision_holds :-
    derived(basic_requirement_satisfied),
    ( derived(cgp_requirement_satisfied) ; derived(previous_result_may_be_considered) ),
    \+ derived(ineligible(_)),
    derived(registration_valid).

check_final_decision(Verbose) :-
    (   final_decision_holds
    ->  ( derived(eligible_for_registration) -> true ; assertz(derived(eligible_for_registration)) ),
        ( fired(final,_) -> true ; assertz(fired(final, eligible_for_registration)) ),
        ( Verbose == true
        -> flag(fw_step, N, N+1),
           format('  Step ~w: FINAL DECISION  ==>  eligible_for_registration~n', [N])
        ; true )
    ;   true
    ).
