//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `no_futures` / `no_futures_or_error`.
//
// The rule fires both on the function declaration (because the body is async
// AND its return type is Future) and inside the body on every Future-typed
// expression. `expect_lint` is matched per-line, not per-fire — one marker
// per offending source line is enough.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

// expect_lint: no_futures_or_error
@noFuturesOrError
Future<void> firesError() async {
  // expect_lint: no_futures_or_error
  await Future<void>.delayed(Duration.zero);
}

// expect_lint: no_futures
@noFutures
Future<void> firesWarning() async {
  // expect_lint: no_futures
  await Future<void>.delayed(Duration.zero);
}

@noFuturesOrError
int doesNotFire(int a, int b) => a + b;
