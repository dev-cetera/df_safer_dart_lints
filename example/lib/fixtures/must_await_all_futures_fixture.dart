//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_await_all_futures` / `must_await_all_futures_or_error`.
// Discarded futures inside an annotated function must fire.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

Future<int> work() async => 1;

@mustAwaitAllFuturesOrError
Future<void> firesError() async {
  // The trailing ignore silences the built-in lints that police the same
  // mistake everywhere; this fixture is about the plugin's rule.
  // expect_lint: must_await_all_futures_or_error
  work(); // ignore: unawaited_futures
}

@mustAwaitAllFutures
Future<void> firesWarning() async {
  // expect_lint: must_await_all_futures
  work(); // ignore: unawaited_futures
}

@mustAwaitAllFuturesOrError
Future<void> doesNotFire_awaited() async {
  await work();
}

@mustAwaitAllFuturesOrError
Future<int> doesNotFire_returned() {
  return work();
}
