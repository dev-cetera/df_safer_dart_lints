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

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Fires on type annotations of the form `Future<Outcome<T>>`,
/// `FutureOr<Outcome<T>>` or `Outcome<Future<T>>`, for every `Outcome`
/// subtype that `df_safer_dart` declares.
final class NoFutureOutcomeTypeRule extends AnalysisRule {
  static const _outcomeTypes = {
    'Outcome',
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

  static final _outcomeCheckers = _outcomeTypes
      .map((name) => NamedTypeChecker(name, packageName: 'df_safer_dart'))
      .toList();

  final LintCode code;

  NoFutureOutcomeTypeRule({required this.code})
    : super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // df_safer_dart is the package that *defines* Async / Resolvable, whose
    // internals fundamentally use Future<Result<T>> / FutureOr<Result<T>>.
    // The rule is for *consumers*, not the implementation.
    if (isInDfSaferDartPackage(context)) return;

    // Only a NamedType (`Future<Result<int>>`) can carry the Future/Outcome
    // nesting this rule looks for: the other TypeAnnotation kinds
    // (GenericFunctionType, RecordTypeAnnotation) resolve to function and
    // record types, and their nested NamedTypes are visited on their own.
    registry.addNamedType(this, _Visitor(this));
  }

  static bool _isFutureOrFutureOr(DartType type) {
    return type.isDartAsyncFuture || type.isDartAsyncFutureOr;
  }

  static bool _isOutcome(DartType type) {
    for (final checker in _outcomeCheckers) {
      if (checker.isExactlyType(type)) {
        return true;
      }
    }
    return false;
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final NoFutureOutcomeTypeRule rule;

  _Visitor(this.rule);

  @override
  void visitNamedType(NamedType node) {
    final type = node.type;
    if (type == null) return;

    if (NoFutureOutcomeTypeRule._isFutureOrFutureOr(type)) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final innerType = type.typeArguments.first;
        if (NoFutureOutcomeTypeRule._isOutcome(innerType)) {
          rule.reportAtNode(node);
        }
      }
    }

    if (NoFutureOutcomeTypeRule._isOutcome(type)) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final innerType = type.typeArguments.first;
        if (NoFutureOutcomeTypeRule._isFutureOrFutureOr(innerType)) {
          rule.reportAtNode(node);
        }
      }
    }
  }
}
