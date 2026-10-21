//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Copyright © dev-cetera.com & contributors.
//
// The use of this source code is governed by an MIT-style license described in
// the LICENSE file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '_rule_test_base.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(MustAwaitAllFuturesTest);
    defineReflectiveTests(MustAwaitAllFuturesOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

Future<int> work() async => 1;

@mustAwaitAllFutures
Future<void> warnFn() async {
  work();
  await work();
}

@mustAwaitAllFuturesOrError
Future<int> errorFn() async {
  work();
  return work();
}

class Worker {
  @mustAwaitAllFutures
  Future<void> method() async {
    work();
  }
}

void run(@mustAwaitAllFutures Future<void> Function() block) {}

void f() {
  run(() async {
    work();
  });
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustAwaitAllFuturesTest extends DfRuleTest {
  @override
  String get ruleName => 'must_await_all_futures';

  Future<void> test_droppedFutures() async {
    await assertDiagnostics(_source, [
      lintIn(_source, '''
Future<void> warnFn() async {
  work();''', 'work()'),
      lintIn(_source, '''
  Future<void> method() async {
    work();''', 'work()'),
      lintIn(_source, '''
  run(() async {
    work();''', 'work()'),
    ]);
  }
}

@reflectiveTest
class MustAwaitAllFuturesOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_await_all_futures_or_error';

  Future<void> test_droppedFuture() async {
    await assertDiagnostics(_source, [
      lintIn(_source, '''
Future<int> errorFn() async {
  work();''', 'work()'),
    ]);
  }
}
