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
    defineReflectiveTests(SendableTest);
    defineReflectiveTests(SendableOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesWarn(@sendable int Function(int) handler) => handler(0);
void takesError(@sendableOrError int Function(int) handler) => handler(0);
void takesNullable(@sendable int Function(int)? handler) => handler?.call(0);
void takesData(@sendable int value) {}

void forward(@sendable int Function(int) handler) => takesWarn(handler);

int topLevel(int x) => x + 1;

class Holder {
  static int staticHandler(int x) => x;
  int instanceHandler(int x) => x;
}

void f(Holder holder) {
  int local(int x) => x;
  takesWarn((x) => x + 1);
  takesWarn(topLevel);
  takesWarn(Holder.staticHandler);
  takesWarn(holder.instanceHandler);
  takesWarn(local);
  takesNullable(null);
  takesData(1);
  takesError((x) => x - 1);
  takesError(topLevel);
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class SendableTest extends DfRuleTest {
  @override
  String get ruleName => 'sendable';

  Future<void> test_closuresAndTearOffs() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesWarn((x) => x + 1)', '(x) => x + 1'),
      lintIn(
        _source,
        'takesWarn(holder.instanceHandler)',
        'holder.instanceHandler',
      ),
      lintIn(_source, 'takesWarn(local)', 'local'),
    ]);
  }
}

@reflectiveTest
class SendableOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'sendable_or_error';

  Future<void> test_closure() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesError((x) => x - 1)', '(x) => x - 1'),
    ]);
  }
}
