%% =====================================================================
%%  FILE: test_cases/test_runner.pl
%%  Runs every test/5 clause and prints expected vs actual
%% =====================================================================

:- multifile test/5.

merge_defaults(Overrides, Facts) :-
    default_facts(Defaults),
    findall(A-V, ( member(A-V, Defaults), \+ memberchk(A-_, Overrides) ), Kept),
    append(Overrides, Kept, Facts).

% The composite final decision (see forward.pl) is not in rule/4, so
% backward chaining for it uses eligible_for_registration/0 directly.
backward_holds(eligible_for_registration) :- !, eligible_for_registration.
backward_holds(Goal) :- prove(Goal, _).

run_test(Id) :-
    test(Id, Desc, Over, Expected, ExpRules),
    merge_defaults(Over, Facts),
    reset_facts,
    forall(member(A-V, Facts), put_fact(A, V)),
    forward_chain(false),
    upcase_atom(Id, UId),
    format('~n~w - ~w~n', [UId, Desc]),
    format('  Changed inputs   : ~w~n', [Over]),
    format('  Expected         : ~w  via ~w~n', [Expected, ExpRules]),
    findall(R, (fired(R,_), R \== final), Rs),
    format('  Actual (forward) : rules fired = ~w~n', [Rs]),
    ( conclusion_message(Expected, M) -> true ; M = Expected ),
    format('  Reasoning        : ~w~n', [M]),
    (   derived(Expected), forall(member(R, ExpRules), memberchk(R, Rs))
    ->  FW = pass ; FW = fail ),
    (   backward_holds(Expected) -> BW = pass ; BW = fail ),
    format('  Forward chaining : ~w~n  Backward chaining: ~w~n', [FW, BW]),
    (   FW == pass, BW == pass -> writeln('  ==> PASS') ; writeln('  ==> FAIL') ).

run_tests :-
    writeln('================ TEST CASES ================'),
    findall(Id, test(Id,_,_,_,_), Ids),
    forall(member(Id, Ids), run_test(Id)),
    reset_facts,
    nl, writeln('============================================').