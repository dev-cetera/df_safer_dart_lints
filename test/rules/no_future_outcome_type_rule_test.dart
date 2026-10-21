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
    defineReflectiveTests(NoFutureOutcomeTypeOrErrorTest);
  });
}

const _source = r'''
import 'dart:async';

import 'package:df_safer_dart/df_safer_dart.dart';

Future<Result<int>>? futureOfResult() => null;
FutureOr<Option<int>>? futureOrOfOption() => null;
Result<Future<int>>? resultOfFuture() => null;

Result<int>? plainResult() => null;
Async<int>? sanctionedAsync() => null;
Future<int>? plainFuture() => null;
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class NoFutureOutcomeTypeOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'no_future_outcome_type_or_error';

  Future<void> test_nestedFutureAndOutcome() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'Future<Result<int>>?'),
      lintIn(_source, 'FutureOr<Option<int>>?'),
      lintIn(_source, 'Result<Future<int>>?'),
    ]);
  }

  Future<void> test_skippedInsideDfSaferDart() async {
    setTestPackageName('df_safer_dart');
    await assertNoDiagnostics(_source);
  }
}
