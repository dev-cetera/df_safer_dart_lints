# Changelog

## 0.5.2

- **feat**: new `sendable` (warning) and `sendable_or_error` (error) lints
  reject arguments to `@sendable` / `@sendableOrError` parameters that
  cannot survive `SendPort.send`. Closures, instance-method tear-offs, and
  local-function references are rejected; top-level functions and static
  methods are accepted. The rule is a no-op for non-function-typed
  parameters.
- Bumps `df_safer_dart_annotations` to `^0.3.1` to pick up the new
  `@sendable` / `@sendableOrError` annotations.

## 0.5.1

- **fix**: `must_use_outcome` now uses `isAssignableFromType` instead of
  `isSuperTypeOf` when matching against `Outcome`. The rule now fires on
  expressions whose static type is assignable to `Outcome` (including
  cases involving generic bounds and other subtyping nuances) that the
  stricter supertype-only check previously missed.

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