import 'dart:async';
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

// A minimal demonstration of df_safer_dart_lints firing.
//
// The function body deliberately uses `Future.value` inside a `@noFutures`
// scope so the lint plugin reports a `no_futures` warning when this file is
// analyzed. The dropped Future is also marked as deliberately discarded with
// `unawaited(...)` so the built-in `discarded_futures` lint is satisfied —
// the diagnostic we want to surface here is the custom `no_futures` one.
@noFutures
void main() {
  // df_safer_dart_lints will warn on this Future inside @noFutures.
  // expect_lint: no_futures
  unawaited(Future<int>.value(1));
}
