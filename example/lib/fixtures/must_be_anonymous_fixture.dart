//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_be_anonymous` / `must_be_anonymous_or_error`.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesAnonymousOrError(@mustBeAnonymousOrError void Function() block) {
  block();
}

void takesAnonymous(@mustBeAnonymous void Function() block) {
  block();
}

void namedFunction() {}

void firesError() {
  // expect_lint: must_be_anonymous_or_error
  takesAnonymousOrError(namedFunction);
}

void firesWarning() {
  // expect_lint: must_be_anonymous
  takesAnonymous(namedFunction);
}

void doesNotFire() {
  takesAnonymousOrError(() {});
}
