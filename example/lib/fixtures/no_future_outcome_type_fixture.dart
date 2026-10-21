//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `no_future_outcome_type_or_error`. Future<Outcome<T>> nesting
// and Outcome<Future<T>> nesting must be flagged at the type-annotation site.

import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';

// expect_lint: no_future_outcome_type_or_error
Future<Result<int>>? fires1() => null;

// expect_lint: no_future_outcome_type_or_error
FutureOr<Option<int>>? fires2() => null;

// expect_lint: no_future_outcome_type_or_error
Future<Resolvable<int>>? fires3() => null;

// Result<int> alone is fine.
Result<int>? doesNotFire1() => null;

// Async<int> is the sanctioned async-Outcome type.
Async<int>? doesNotFire2() => null;

// Future<int> alone is fine (just no Outcome inside).
Future<int>? doesNotFire3() => null;
