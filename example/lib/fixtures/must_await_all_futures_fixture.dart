//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// Fixture for `must_await_all_futures` / `must_await_all_futures_or_error`.
// Discarded futures inside an annotated function must fire.

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

Future<int> work() async => 1;

@mustAwaitAllFuturesOrError
Future<void> firesError() async {
  //work();
}

@mustAwaitAllFutures
Future<void> firesWarning() async {
  //work();
}

@mustAwaitAllFuturesOrError
Future<void> doesNotFire_awaited() async {
  await work();
}

@mustAwaitAllFuturesOrError
Future<int> doesNotFire_returned() {
  return work();
}
