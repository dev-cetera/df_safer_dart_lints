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
    defineReflectiveTests(MustHandleReturnTest);
    defineReflectiveTests(MustHandleReturnOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

@mustHandleReturn
int warnFn() => 1;

@mustHandleReturnOrError
String errorFn() => '';

class Box {
  @mustHandleReturn
  int get getter => 1;

  @mustHandleReturn
  int method() => 1;
}

Future<void> f(Box box) async {
  warnFn();
  (warnFn());
  box.method();
  box.getter;
  final kept = warnFn();
  print(kept + box.getter);
  errorFn();
  print(errorFn());
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustHandleReturnTest extends DfRuleTest {
  @override
  String get ruleName => 'must_handle_return';

  Future<void> test_droppedResults() async {
    await assertDiagnostics(_source, [
      lintIn(_source, '  warnFn();', 'warnFn()'),
      lintIn(_source, '(warnFn())', 'warnFn()'),
      lintIn(_source, 'box.method()'),
      lintIn(_source, 'box.getter;', 'box.getter'),
    ]);
  }
}

@reflectiveTest
class MustHandleReturnOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_handle_return_or_error';

  Future<void> test_droppedResult() async {
    await assertDiagnostics(_source, [
      lintIn(_source, '  errorFn();', 'errorFn()'),
    ]);
  }
}
