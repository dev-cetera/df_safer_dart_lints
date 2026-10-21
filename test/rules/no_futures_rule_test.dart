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
    defineReflectiveTests(NoFuturesTest);
    defineReflectiveTests(NoFuturesOrErrorTest);
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class NoFuturesTest extends DfRuleTest {
  @override
  String get ruleName => 'no_futures';

  Future<void> test_asyncFunction() async {
    const source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

@noFutures
Future<void> f() async {
  await Future<void>.delayed(Duration.zero);
}
''';
    const declaration = '''
@noFutures
Future<void> f() async {
  await Future<void>.delayed(Duration.zero);
}''';
    await assertDiagnostics(source, [
      // The rule reports the declaration twice (for `async` and for the
      // Future return type); the analyzer collapses identical diagnostics.
      lintIn(source, declaration),
      lintIn(source, 'await Future<void>.delayed(Duration.zero)'),
      lintIn(
        source,
        'await Future<void>.delayed(Duration.zero)',
        'Future<void>.delayed(Duration.zero)',
      ),
    ]);
  }

  Future<void> test_annotatedParameter() async {
    const source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void run(@noFutures void Function() block) => block();

void f() {
  run(() async {});
}
''';
    await assertDiagnostics(source, [
      lintIn(source, '() async {}'),
    ]);
  }

  Future<void> test_synchronousAndSafeContext() async {
    await assertNoDiagnostics(r'''
import 'package:df_safer_dart/df_safer_dart.dart';

@noFutures
int add(int a, int b) => a + b;

@noFutures
Resolvable<int> bridged() => Async(() async => 1);

class Calculator {
  @noFutures
  int twice(int a) => a * 2;
}
''');
  }

  Future<void> test_errorVariantDoesNotFireWarning() async {
    await assertNoDiagnostics(r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

@noFuturesOrError
Future<void> f() async {}
''');
  }

  Future<void> test_skippedInsideDfSaferDart() async {
    setTestPackageName('df_safer_dart');
    await assertNoDiagnostics(r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

@noFutures
Future<void> f() async {}
''');
  }
}

@reflectiveTest
class NoFuturesOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'no_futures_or_error';

  Future<void> test_method() async {
    const source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

Future<int> work() async => 1;

class Worker {
  @noFuturesOrError
  void run() {
    final pending = work();
    print(pending);
  }
}
''';
    await assertDiagnostics(source, [
      lintIn(source, 'final pending = work()', 'work()'),
    ]);
  }
}
