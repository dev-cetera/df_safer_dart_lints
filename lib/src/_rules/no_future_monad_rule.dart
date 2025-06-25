// lib/src/_rules/avoid_nested_futures_in_monads_rule.dart

//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// Dart/Flutter (DF) Packages by dev-cetera.com & contributors. The use of this
// source code is governed by an MIT-style license described in the LICENSE
// file located in this project's root directory.
//
// See: https://opensource.org/license/mit
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// ignore_for_file: deprecated_member_use

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class NoFutureMonadTypeRule extends DartLintRule {
  static const _monadTypes = {
    'Monad',
    'Option',
    'Some',
    'None',
    'Result',
    'Ok',
    'Err',
    'Resolvable',
    'Sync',
    'Async',
  };

  static final _monadCheckers = _monadTypes
      .map((name) => TypeChecker.fromName(name, packageName: 'df_safer_dart'))
      .toList();

  const NoFutureMonadTypeRule({required super.code});

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addTypeAnnotation((node) {
      final type = node.type;
      if (type == null) return;

      if (_isFutureOrFutureOr(type)) {
        if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
          final innerType = type.typeArguments.first;
          if (_isMonad(innerType)) {
            reporter.atNode(node, code);
          }
        }
      }

      if (_isMonad(type)) {
        if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
          final innerType = type.typeArguments.first;
          if (_isFutureOrFutureOr(innerType)) {
            reporter.atNode(node, code);
          }
        }
      }
    });
  }

  bool _isFutureOrFutureOr(DartType type) {
    return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
  }

  bool _isMonad(DartType type) {
    for (final checker in _monadCheckers) {
      if (checker.isExactlyType(type)) {
        return true;
      }
    }
    return false;
  }
}
