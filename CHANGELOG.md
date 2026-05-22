# Changelog

## 0.5.0

- **fix**: `must_be_strong_ref` no longer fires when a top-level function or
  a static method is passed to a `@mustBeStrongRef` parameter. Both have
  program-/class-lifetime references by definition, so they are valid
  "strong" refs. Previously only instance-method tear-offs were accepted.
- **feat**: `must_handle_return` is no longer `@Deprecated`. Use it
  alongside `@useResult` for the warning-vs-error split. The rule's doc
  comment now mentions `@useResult` as the standard alternative for new
  code.
- **perf**: `must_use_unsafe_wrapper` and `must_handle_return` skip
  doc-comment references with an O(1) `node.parent is CommentReference`
  check instead of walking the parent chain. These rules fire on every
  identifier in a file, so the win is felt on every analyzer pass.
- **perf**: `must_handle_return` reorders its checks so the cheap parent
  walk (`_isResultUnused`) runs before the element-metadata walk
  (`_hasMustHandleReturnAnnotation`).

## 0.4.1

- **Perf**: `must_use_unsafe_wrapper` and `must_handle_return` now skip
  doc-comment references with an O(1) parent check (`node.parent is
  CommentReference`) instead of walking the parent chain.
- **Perf**: `must_handle_return` reorders checks so the cheap parent-walk
  runs before the element-metadata walk.

## 0.4.0

- **Fix**: `must_use_unsafe_wrapper` / `_or_error` no longer fires on
  identifiers inside doc-comment links (e.g. `[Outcome.unwrap]` in `///`
  comments) — those are documentation, not call sites.
- **Fix**: same fix applied to `must_handle_return` / `_or_error`.
- Removed the self-referential `custom_lint` plugin from this package's own
  `analysis_options.yaml` — a lint plugin can't lint itself.
- Added an end-to-end coverage suite at
  `test/lint_fixtures_test.dart`. Each rule has a fixture under
  `example/lib/fixtures/<rule>_fixture.dart` that uses `// expect_lint:`
  markers. The test runs `dart run custom_lint` over the fixtures and
  asserts every marker is satisfied with no extras.
- Tightened `analysis_options.yaml` with the same safety-oriented additions
  used by `df_safer_dart`.
- README rewritten with the rule list, fixture explanation, and the
  doc-comment / `UNSAFE`-URI detection notes.
