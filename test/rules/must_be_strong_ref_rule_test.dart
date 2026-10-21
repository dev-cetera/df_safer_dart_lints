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
    defineReflectiveTests(MustBeStrongRefTest);
    defineReflectiveTests(MustBeStrongRefOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

void takesWarn(@mustBeStrongRef void Function() listener) => listener();
void takesError(@mustBeStrongRefOrError void Function() listener) => listener();

void topLevel() {}

class Holder {
  final void Function() stored = topLevel;
  static void staticMethod() {}
  void instanceMethod() {}
}

void f(Holder holder) {
  final variable = topLevel;
  void local() {}
  takesWarn(() {});
  takesWarn(variable);
  takesWarn(topLevel);
  takesWarn(Holder.staticMethod);
  takesWarn(holder.stored);
  takesWarn(holder.instanceMethod);
  takesWarn(local);
  takesError(() {});
  takesError(topLevel);
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustBeStrongRefTest extends DfRuleTest {
  @override
  String get ruleName => 'must_be_strong_ref';

  Future<void> test_literalsAndShortLivedReferences() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesWarn(() {})', '() {}'),
      lintIn(
        _source,
        'takesWarn(holder.instanceMethod)',
        'holder.instanceMethod',
      ),
      lintIn(_source, 'takesWarn(local)', 'local'),
    ]);
  }
}

@reflectiveTest
class MustBeStrongRefOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_be_strong_ref_or_error';

  Future<void> test_functionLiteral() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'takesError(() {})', '() {}'),
    ]);
  }
}
