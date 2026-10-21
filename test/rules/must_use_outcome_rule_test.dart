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
    defineReflectiveTests(MustUseOutcomeOrErrorTest);
  });
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustUseOutcomeOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_use_outcome_or_error';

  Future<void> test_droppedOutcome() async {
    const source = r'''
import 'package:df_safer_dart/df_safer_dart.dart';

Sync<int> makeSync() => Sync(() => 1);
Result<int> makeResult() => const Ok(1);

void f() {
  makeSync();
  makeResult();
}
''';
    await assertDiagnostics(source, [
      lintIn(source, '  makeSync();', 'makeSync()'),
      lintIn(source, '  makeResult();', 'makeResult()'),
    ]);
  }

  Future<void> test_usedOrVoidOutcome() async {
    await assertNoDiagnostics(r'''
import 'package:df_safer_dart/df_safer_dart.dart';

Sync<int> makeSync() => Sync(() => 1);

void f() {
  final _ = makeSync();
  Outcome<int> assigned;
  assigned = makeSync();
  print(assigned);
  makeSync().end();
  print('void expressions are exempt');
}
''');
  }
}
