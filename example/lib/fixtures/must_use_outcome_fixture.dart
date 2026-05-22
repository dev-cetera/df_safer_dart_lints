//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for the `must_use_outcome_or_error` rule.
// Outcome values dropped as bare expression statements must be flagged.


import 'package:df_safer_dart/df_safer_dart.dart';

Sync<int> makeSync() => Sync(() => 1);

void fires() {
  // The expression below produces a Sync<int> that is immediately discarded.
  // expect_lint: must_use_outcome_or_error
  makeSync();
}

void doesNotFire_assignment() {
  // Assigning the Outcome counts as "used".
  final _ = makeSync();
}

void doesNotFire_chain() {
  // Calling .end() is the documented suppression for "I really want to throw
  // this Outcome away on purpose."
  makeSync().end();
}

void doesNotFire_voidExpression() {
  // Void expressions are exempt.
  print('hi');
}
