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