%% =====================================================================
%%  FILE: inference.pl
%%  Condition testing + backward chaining (goal -> facts)
%% =====================================================================

%% ---- Condition testing against the raw facts (known/2) --------------
test_base(eq(A,V))       :- known(A,V).
test_base(cmp(A,Op,V))   :- known(A,X), number(X), G =.. [Op,X,V], call(G).
test_base(in(A,List))    :- known(A,X), memberchk(X,List).

%% ---- Backward chaining meta-interpreter ------------------------------
%%  prove(Goal, ProofTree): to prove Goal, find a rule that concludes it
%%  and recursively prove that rule's conditions, down to the raw facts.
prove(Goal, node(Goal, Id, Kids)) :-
    rule(Id, _, Conds, Goal),
    prove_all(Conds, Kids).

prove_all([], []).
prove_all([C|Cs], [K|Ks]) :- prove_cond(C, K), prove_all(Cs, Ks).

prove_cond(derived(G), P)  :- prove(G, P).
prove_cond(no(G), neg(G))  :- \+ prove(G, _).
prove_cond(or(A,B), K)     :- ( prove_cond(A, K) ; prove_cond(B, K) ).
prove_cond(C, leaf(C))     :- test_base(C).

%% ---- The composite final decision (see forward.pl for why it is not
%%      a single numbered rule). This lets you type, straight in Prolog:
%%        ?- eligible_for_registration.
eligible_for_registration :-
    prove(basic_requirement_satisfied, _),
    ( prove(cgp_requirement_satisfied, _) ; prove(previous_result_may_be_considered, _) ),
    \+ prove(ineligible(_), _),
    prove(registration_valid, _).

final_proof(final_decision(B, C, not_ineligible, R)) :-
    prove(basic_requirement_satisfied, B),
    ( prove(cgp_requirement_satisfied, C) -> true ; prove(previous_result_may_be_considered, C) ),
    \+ prove(ineligible(_), _),
    prove(registration_valid, R).

%% ---- Printing a proof tree --------------------------------------------
print_proof(node(G,Id,Kids), In) :-
    indent(In), upcase_atom(Id,U),
    format('~w  <=  proved by ~w~n', [G,U]),
    In2 is In + 4,
    forall(member(K,Kids), print_proof(K, In2)).
print_proof(leaf(C), In) :-
    indent(In), write('FACT: '), describe_cond(C), nl.
print_proof(neg(G), In) :-
    indent(In), format('NOT ~w  (cannot be proven, as required)~n', [G]).

indent(N) :- forall(between(1,N,_), put_char(' ')).

backward_report :-
    writeln('--- BACKWARD CHAINING TRACE ---'),
    writeln('MAIN GOAL: eligible_for_registration'),
    writeln('  (combination of R01-R04, R05-R15 and R16-R18 - see forward.pl)'),
    (   final_proof(final_decision(B,C,_,R))
    ->  writeln('  Sub-goal: basic_requirement_satisfied'),
        print_proof(B, 4),
        writeln('  Sub-goal: cgp_requirement_satisfied / previous_result_may_be_considered'),
        print_proof(C, 4),
        writeln('  Sub-goal: no ineligible(_) can be proven  ... confirmed'),
        writeln('  Sub-goal: registration_valid'),
        print_proof(R, 4),
        writeln('  RESULT: goal PROVEN.')
    ;   writeln('  RESULT: goal CANNOT be proven. Failing sub-goals:'),
        ( \+ prove(basic_requirement_satisfied,_) -> writeln('    x basic_requirement_satisfied could not be established') ; true ),
        ( \+ prove(cgp_requirement_satisfied,_), \+ prove(previous_result_may_be_considered,_)
          -> writeln('    x neither cgp_requirement_satisfied nor previous_result_may_be_considered could be established') ; true ),
        ( prove(ineligible(Why),_) -> format('    x candidate IS ineligible: ~w~n', [Why]) ; true ),
        ( \+ prove(registration_valid,_) -> writeln('    x registration_valid could not be established') ; true )
    ),
    setof(H, I^S^Co^rule(I,S,Co,H), Heads),
    forall(( member(G, Heads), \+ derived_head_needs_skip(G), prove(G, PG) ),
           ( format('~nGOAL: ~w~n', [G]), print_proof(PG, 2) )).

% avoid re-printing goals already fully expanded above
derived_head_needs_skip(basic_requirement_satisfied).
derived_head_needs_skip(cgp_requirement_satisfied).
derived_head_needs_skip(previous_result_may_be_considered).
derived_head_needs_skip(registration_valid).