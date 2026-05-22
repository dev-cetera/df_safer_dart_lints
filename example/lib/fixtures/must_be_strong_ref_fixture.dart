//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_be_strong_ref` / `must_be_strong_ref_or_error`.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesStrongRefOrError(
  @mustBeStrongRefOrError void Function() listener,
) {
  listener();
}

void takesStrongRef(@mustBeStrongRef void Function() listener) {
  listener();
}

void firesError() {
  // Anonymous closures are NOT strong refs — they get collected the moment
  // the local frame disappears.
  // expect_lint: must_be_strong_ref_or_error
  takesStrongRefOrError(() {});
}

void firesWarning() {
  // expect_lint: must_be_strong_ref
  takesStrongRef(() {});
}

void doesNotFire() {
  // A real top-level function is the canonical "strong" reference — it can
  // outlive the local frame.
  takesStrongRefOrError(_listener);
}

void _listener() {}
