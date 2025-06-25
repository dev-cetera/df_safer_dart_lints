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

final class NoFuturesRule extends DartLintRule {
  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  NoFuturesRule({
    required super.code,
    required this.shortName,
    required this.longName,
  });

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionDeclaration((node) {
      if (isDirectlyAnnotatedByText(node, shortName, longName)) {
        _checkFunction(node.functionExpression, reporter, node);
      }
    });

    context.registry.addFunctionExpression((node) {
      if (node.parent is FunctionDeclaration) return;

      final paramElement = node.staticParameterElement;
      if (paramElement != null && _checker.hasAnnotationOf(paramElement)) {
        _checkFunction(node, reporter, node);
      }
    });
  }

  void _checkFunction(
    FunctionExpression node,
    ErrorReporter reporter,
    AstNode errorNode,
  ) {
    if (node.body.isAsynchronous) {
      reporter.atNode(errorNode, code, arguments: [shortName]);
    }
    final returnType = node.declaredElement?.returnType;
    if (_isFutureOrFutureOr(returnType)) {
      reporter.atNode(errorNode, code, arguments: [shortName]);
    }
    node.body.accept(_NoFuturesVisitor(reporter: reporter, code: code));
  }
}

bool _isFutureOrFutureOr(DartType? type) {
  return type != null && (type.isDartAsyncFuture || type.isDartAsyncFutureOr);
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _NoFuturesVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final LintCode code;

  int _safeContextDepth = 0;
  bool get _isInSafeContext => _safeContextDepth > 0;

  static final _asyncChecker = const TypeChecker.fromName(
    'Async',
    packageName: 'df_safer_dart',
  );

  static final _resolvableChecker = const TypeChecker.fromName(
    'Resolvable',
    packageName: 'df_safer_dart',
  );

  _NoFuturesVisitor({required this.reporter, required this.code});

  void _check(Expression node) {
    if (_isInSafeContext) return;
    if (_isFutureOrFutureOr(node.staticType)) {
      reporter.atNode(node, code);
    }
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (!_isInSafeContext) {
      reporter.atNode(node, code);
    }
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.body.isAsynchronous && !_isInSafeContext) {
      reporter.atNode(node.body, code);
    }
    if (_isFutureOrFutureOr(node.declaredElement?.returnType) &&
        !_isInSafeContext) {
      reporter.atNode(node, code);
    }
    super.visitFunctionExpression(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.staticType;
    if (type != null &&
        (_asyncChecker.isExactlyType(type) ||
            _resolvableChecker.isExactlyType(type))) {
      _safeContextDepth++;
      super.visitInstanceCreationExpression(node);
      _safeContextDepth--;
    } else {
      _check(node);
      super.visitInstanceCreationExpression(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _check(node);
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _check(node);
    super.visitFunctionExpressionInvocation(node);
  }
}
