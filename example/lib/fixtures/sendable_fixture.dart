//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `sendable` / `sendable_or_error`.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesSendableOrError(@sendableOrError int Function(int) handler) {
  handler(0);
}

void takesSendable(@sendable int Function(int) handler) {
  handler(0);
}

int topLevelHandler(int x) => x + 1;

class _Holder {
  static int staticHandler(int x) => x + 1;
  int instanceHandler(int x) => x + 1;
}

void firesErrorOnClosure() {
  // expect_lint: sendable_or_error
  takesSendableOrError((x) => x + 1);
}

void firesWarningOnClosure() {
  // expect_lint: sendable
  takesSendable((x) => x + 1);
}

void firesErrorOnInstanceTearOff() {
  final holder = _Holder();
  // expect_lint: sendable_or_error
  takesSendableOrError(holder.instanceHandler);
}

void firesErrorOnLocalVariable() {
  int local(int x) => x + 1;
  // expect_lint: sendable_or_error
  takesSendableOrError(local);
}

void doesNotFireOnTopLevelFn() {
  takesSendableOrError(topLevelHandler);
}

void doesNotFireOnStaticMethod() {
  takesSendableOrError(_Holder.staticHandler);
}
