//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_use_unsafe_wrapper` / `must_use_unsafe_wrapper_or_error`.

import 'package:df_safer_dart/df_safer_dart.dart';

void firesOnUnwrap() {
  const Result<int> r = Ok<int>(1);
  // .unwrap() is @unsafeOrError and must live inside an UNSAFE() block.
  // expect_lint: must_use_unsafe_wrapper_or_error
  final value = r.unwrap();
  print(value);
}

void doesNotFire_insideUnsafe() {
  const Result<int> r = Ok<int>(1);
  // UNSAFE requires an inline lambda (@mustBeAnonymous on its parameter), so
  // we can't tear off `r.unwrap` here. The block body keeps the
  // `unnecessary_lambdas` hint quiet too.
  final value = UNSAFE(() {
    return r.unwrap();
  });
  print(value);
}

void doesNotFire_handledOutcome() {
  const Result<int> r = Ok<int>(1);
  // Pattern-matching is the recommended safe alternative.
  switch (r) {
    case Ok(value: final v):
      print(v);
    case Err err:
      print(err.error);
  }
}

/// The doc-comment reference below must NOT fire — it's documentation, not a
/// call site. This is the regression introduced when the lint rule started
/// scanning [Outcome.unwrap] and friends.
void doesNotFire_inDocComment() {}
