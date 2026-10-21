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
    defineReflectiveTests(MustBeAnonymousTest);
    defineReflectiveTests(MustBeAnonymousOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesWarn(@mustBeAnonymous void Function() block) => block();
void takesError(@mustBeAnonymousOrError void Function() block) => block();
void takesNamed({@mustBeAnonymous required void Function() block}) => block();

void named() {}

void f() {
  takesWarn(named);
  takesWarn(() {});
  takesNamed(block: named);
  takesNamed(block: () {});
  takesError(named);
  takesError(() {});
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustBeAnonymousTest extends DfRuleTest {
  @override
  String get ruleName => 'must_be_anonymous';

  Future<void> test_namedFunction_positionalAndNamed() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesWarn(named)', 'named'),
      lintIn(_source, 'takesNamed(block: named)', 'named'),
    ]);
  }

  Future<void> test_functionLiteral() async {
    await assertNoDiagnostics(r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takes(@mustBeAnonymous void Function() block) => block();

void f() {
  takes(() {});
  takes(() => print('hi'));
}
''');
  }
}

@reflectiveTest
class MustBeAnonymousOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_be_anonymous_or_error';

  Future<void> test_namedFunction() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesError(named)', 'named'),
    ]);
  }
}
