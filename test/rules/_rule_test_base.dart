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

// Shared setup for the per-rule tests in this directory.
//
// Each test analyses a small in-memory package with one rule enabled, using
// `AnalysisRuleTest` from package:analyzer_testing. The two packages the
// rules inspect, df_safer_dart_annotations and df_safer_dart, are replaced
// by the minimal mocks below: the rules match types by name and package, so
// a mock with the same names and package names behaves like the real thing.

import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
// ExpectedDiagnostic is what `lint(...)` returns, but the package does not
// export the type itself.
// ignore: implementation_imports
import 'package:analyzer_testing/src/analysis_rule/pub_package_resolution.dart'
    show ExpectedDiagnostic;
import 'package:df_safer_dart_lints/df_safer_dart_lints.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

abstract class DfRuleTest extends AnalysisRuleTest {
  /// The name of the rule under test, exactly as the plugin registers it.
  String get ruleName;

  @override
  void setUp() {
    rule = createDfSaferDartRules().singleWhere((r) => r.name == ruleName);
    // The mock packages must be registered before `super.setUp()`, which
    // writes the package config that makes them importable.
    newPackage('df_safer_dart_annotations').addFile(
      'lib/df_safer_dart_annotations.dart',
      _annotationsMock,
    );
    newPackage('df_safer_dart').addFile(
      'lib/df_safer_dart.dart',
      _saferDartMock,
    );
    super.setUp();
  }

  /// Expects the rule under test on [snippet] (default: all of [context]),
  /// where [context] is a piece of [content] that occurs exactly once and
  /// contains [snippet].
  ExpectedDiagnostic lintIn(String content, String context, [String? snippet]) {
    final contextOffset = content.indexOf(context);
    if (contextOffset < 0 || contextOffset != content.lastIndexOf(context)) {
      throw ArgumentError('`$context` must occur exactly once in the source');
    }
    final target = snippet ?? context;
    final snippetOffset = context.indexOf(target);
    if (snippetOffset < 0) {
      throw ArgumentError('`$target` does not occur in `$context`');
    }
    return lint(contextOffset + snippetOffset, target.length);
  }

  /// Rewrites the test package's pubspec so it declares [name].
  void setTestPackageName(String name) {
    newFile(testPackagePubspecPath, 'name: $name\n');
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

const _annotationsMock = r'''
const mustAwaitAllFutures = MustAwaitAllFuturesAnnotation();
final class MustAwaitAllFuturesAnnotation { const MustAwaitAllFuturesAnnotation(); }
const mustAwaitAllFuturesOrError = MustAwaitAllFuturesOrErrorAnnotation();
final class MustAwaitAllFuturesOrErrorAnnotation { const MustAwaitAllFuturesOrErrorAnnotation(); }

const mustBeAnonymous = MustBeAnonymousAnnotation();
final class MustBeAnonymousAnnotation { const MustBeAnonymousAnnotation(); }
const mustBeAnonymousOrError = MustBeAnonymousOrErrorAnnotation();
final class MustBeAnonymousOrErrorAnnotation { const MustBeAnonymousOrErrorAnnotation(); }

const mustBeStrongRef = MustBeStrongRefAnnotation();
final class MustBeStrongRefAnnotation { const MustBeStrongRefAnnotation(); }
const mustBeStrongRefOrError = MustBeStrongRefOrErrorAnnotation();
final class MustBeStrongRefOrErrorAnnotation { const MustBeStrongRefOrErrorAnnotation(); }

const mustHandleReturn = MustHandleReturnAnnotation();
final class MustHandleReturnAnnotation { const MustHandleReturnAnnotation(); }
const mustHandleReturnOrError = MustHandleReturnOrErrorAnnotation();
final class MustHandleReturnOrErrorAnnotation { const MustHandleReturnOrErrorAnnotation(); }

const noFutures = NoFuturesAnnotation();
final class NoFuturesAnnotation { const NoFuturesAnnotation(); }
const noFuturesOrError = NoFuturesOrErrorAnnotation();
final class NoFuturesOrErrorAnnotation { const NoFuturesOrErrorAnnotation(); }

const sendable = SendableAnnotation();
final class SendableAnnotation { const SendableAnnotation(); }
const sendableOrError = SendableOrErrorAnnotation();
final class SendableOrErrorAnnotation { const SendableOrErrorAnnotation(); }

const unsafe = UnsafeAnnotation();
final class UnsafeAnnotation { const UnsafeAnnotation(); }
const unsafeOrError = UnsafeOrErrorAnnotation();
final class UnsafeOrErrorAnnotation { const UnsafeOrErrorAnnotation(); }
''';

const _saferDartMock = r'''
import 'dart:async';

import 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

export 'package:df_safer_dart_annotations/df_safer_dart_annotations.dart';

T UNSAFE<T>(@mustBeAnonymous T Function() block) => block();

sealed class Outcome<T> {
  const Outcome();
  void end() {}
}

sealed class Option<T> extends Outcome<T> {
  const Option();
}

final class Some<T> extends Option<T> {
  final T value;
  const Some(this.value);
}

final class None<T> extends Option<T> {
  const None();
}

sealed class Result<T> extends Outcome<T> {
  const Result();

  @unsafeOrError
  T unwrap();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  T unwrap() => value;
}

final class Err<T> extends Result<T> {
  final Object error;
  const Err(this.error);

  @override
  T unwrap() => throw error;
}

sealed class Resolvable<T> extends Outcome<T> {
  const Resolvable._();
  factory Resolvable(FutureOr<T> Function() block) => Async(() async => block());
}

final class Sync<T> extends Resolvable<T> {
  final T Function() block;
  const Sync(this.block) : super._();
}

final class Async<T> extends Resolvable<T> {
  final Future<T> Function() block;
  const Async(this.block) : super._();

  @unsafe
  static Async<T> unsafeOk<T>(T value) => Async(() async => value);
}
''';
