# UGC University Admission & Registration Expert System (25 rules)

Run:   swipl main.pl      then   ?- main.        (menu)
Tests: swipl main.pl      then   ?- run_tests.    (19 test cases, all pass)

| File                       | Contents                                                          |
|----------------------------|--------------------------------------------------------------------|
| main.pl                    | Loads all files, CLI menu, user input questions                   |
| facts.pl                   | Dynamic fact storage, put_fact/reset_facts, 30 default facts       |
| rules.pl                   | Rule base R01-R25 as rule(Id, Stratum, Conditions, Conclusion)     |
| forward.pl                 | Forward chaining engine + composite "final decision" computation   |
| inference.pl               | Condition testing + backward chaining (prove/2, proof tree)        |
| explanation.pl             | Rule explanations, messages, reasoning output, verdicts            |
| test_cases/test01-19.pl    | One test case per file (matches the 25-rule specification table)  |
| test_cases/test_runner.pl  | Runs all tests, compares expected vs actual                        |

## Notes
- R01-R25 match the Rule Specification Table exactly (see comments in rules.pl,
  each rule cites its handbook section).
- "eligible_for_registration" is a composite FINAL decision (not rule-numbered),
  combining R01-R04 + R05-R15 + R16-R18 - see forward.pl / inference.pl.
- R11 (60-day exception) only applies if R12 (vacancy entry) has NOT fired -
  demonstrated in test13.pl vs test14.pl.
- R16 ties into R18: registration_valid requires either online payment, or
  bank payment WITH a voucher.
