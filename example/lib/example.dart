import 'dart:async';
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

// ignore_for_file: no_futures

@noFutures
void main() {
  Future.value(1); // throws a warning!
}
