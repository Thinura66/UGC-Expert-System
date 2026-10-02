# UGC University Admission & Registration Expert System

This is a command-line expert system implemented in SWI-Prolog. It checks
admission eligibility, registration requirements, and course/Uni-Code
preferences using 25 rules. It supports forward chaining, backward chaining,
and explanations for the rules that fired.

## Prerequisites

Install [SWI-Prolog](https://www.swi-prolog.org/Download.html) and make sure
the `swipl` command is available in your terminal.

Verify the installation:

```text
swipl --version
```

Run all commands below from the project root (the directory containing
`main.pl`).

## Run the expert system

Start SWI-Prolog and load the application:

```text
swipl main.pl
```

At the Prolog prompt, start the menu:

```prolog
?- main.
```

Choose an option from the menu and answer the questions shown. The main menu
provides these operations:

1. Check admission eligibility
2. Check registration requirements
3. Check course and Uni-Code preferences
4. Run a full check
5. Run a full check and show reasoning automatically
6. View forward and backward reasoning for the last check
7. Run the test cases
8. Exit

To stop the application from the Prolog prompt, use `Ctrl+D` on Linux/macOS
or choose option `8`.

### Start the menu directly

The menu can also be started without entering `?- main.`:

```text
swipl -s main.pl -g main -t halt
```

## Run the automated tests

From the project root, start SWI-Prolog:

```text
swipl main.pl
```

Then run the test suite:

```prolog
?- run_tests.
```

The suite runs 19 test cases and prints the expected result, rules fired, and
forward/backward chaining status for each case.

For a non-interactive test run:

```text
swipl -s main.pl -g run_tests -t halt
```

## Project files

| File | Contents |
|---|---|
| `main.pl` | Loads all files, provides the CLI menu, and collects user input |
| `facts.pl` | Dynamic fact storage and default facts used by the tests |
| `rules.pl` | Rule base R01-R25 |
| `forward.pl` | Forward-chaining engine and composite final-decision computation |
| `inference.pl` | Condition testing and backward chaining (`prove/2`, proof tree) |
| `explanation.pl` | Rule explanations, messages, reasoning output, and verdicts |
| `test_cases/test01.pl`–`test19.pl` | Individual test cases |
| `test_cases/test_runner.pl` | Runs all tests and compares expected with actual results |

## Notes

- R01-R25 match the Rule Specification Table in `rules.pl`.
- `eligible_for_registration` is a composite final decision, not a numbered
  rule. It combines R01-R04, R05-R15, and R16-R18.
- R11 (the 60-day exception) applies only when R12 (vacancy entry) has not
  fired.
- R16 ties into R18: `registration_valid` requires either online payment or
  bank payment with a voucher.
