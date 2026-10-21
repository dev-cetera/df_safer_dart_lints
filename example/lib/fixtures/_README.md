# Lint coverage fixtures

Each file here exercises **one** rule pair from `df_safer_dart_lints`. Sites
that should fire a rule are annotated with `// expect_lint: <rule_name>` on the
line *immediately above* the offending code (several names may be listed,
comma-separated). The contract is matched per line, not per diagnostic:

- If `expect_lint` names a rule that does **not** fire on the next line → the
  test fails.
- If one of this plugin's rules fires on a line without a matching
  `expect_lint` → the test fails.

`test/lint_fixtures_test.dart` runs `dart analyze --format=machine` in
`example/`, where `analysis_options.yaml` enables this checkout as an analyzer
plugin, and checks every marker. Diagnostics that do not come from this plugin
are ignored.
