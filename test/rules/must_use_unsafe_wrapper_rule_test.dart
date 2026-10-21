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
    defineReflectiveTests(MustUseUnsafeWrapperTest);
    defineReflectiveTests(MustUseUnsafeWrapperOrErrorTest);
  });
}

const _source = r'''
import 'package:df_safer_dart/df_safer_dart.dart';

class Box {
  @unsafeOrError
  final int risky = 1;
}

/// Documentation links such as [Result.unwrap] are not call sites.
void f(Box box) {
  const Result<int> r = Ok<int>(1);
  final a = r.unwrap();
  final b = box.risky;
  final c = Async.unsafeOk(1);
  final d = UNSAFE(() => r.unwrap());
  final e = UNSAFE(() => Async.unsafeOk(1));
  // ignore: unused_label
  UNSAFE:
  {
    final g = r.unwrap();
    print(g);
  }
  print([a, b, c, d, e]);
}
''';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

@reflectiveTest
class MustUseUnsafeWrapperTest extends DfRuleTest {
  @override
  String get ruleName => 'must_use_unsafe_wrapper';

  Future<void> test_unsafeStaticMethod() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'final c = Async.unsafeOk(1)', 'Async.unsafeOk(1)'),
    ]);
  }
}

@reflectiveTest
class MustUseUnsafeWrapperOrErrorTest extends DfRuleTest {
  @override
  String get ruleName => 'must_use_unsafe_wrapper_or_error';

  Future<void> test_unsafeOrErrorMembers() async {
    await assertDiagnostics(_source, [
      lintIn(_source, 'final a = r.unwrap()', 'r.unwrap()'),
      lintIn(_source, 'box.risky'),
    ]);
  }

  Future<void> test_skippedInsideDfSaferDart() async {
    setTestPackageName('df_safer_dart');
    await assertNoDiagnostics(_source);
  }
}
