# Lint coverage fixtures

Each file here exercises **one** rule from `df_safer_dart_lints`. Sites that
should fire the rule are annotated with `// expect_lint: <rule_name>` on the
line *immediately above* the offending expression. Custom_lint enforces this
contract:

- If `expect_lint` appears but the rule does **not** fire on the next line →
  custom_lint reports it as a test failure.
- If the rule fires on a line that does **not** have a matching `expect_lint`
  → custom_lint reports it as an unexpected diagnostic.

The accompanying `test/lint_fixtures_test.dart` runs `dart run custom_lint`
over this directory and asserts exit code 0.
