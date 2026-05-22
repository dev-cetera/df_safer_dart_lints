//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_handle_return` / `must_handle_return_or_error`.


import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

@mustHandleReturnOrError
String importantString() => 'load-bearing';

@mustHandleReturn
int importantInt() => 42;

void firesError() {
  // expect_lint: must_handle_return_or_error
  importantString();
}

void firesWarning() {
  // expect_lint: must_handle_return
  importantInt();
}

void doesNotFire_assigned() {
  final _ = importantString();
  final __ = importantInt();
}
