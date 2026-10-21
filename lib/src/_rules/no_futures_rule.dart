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

/// Fires when a function or method annotated `@noFutures` /
/// `@noFuturesOrError` (or a function literal passed to a parameter with that
/// annotation) is `async`, returns a `Future`, or contains a `Future`.
///
/// Futures wrapped in `Async(...)` / `Resolvable(...)` from `df_safer_dart`
/// are the sanctioned way to bridge async work, so they are not reported.
final class NoFuturesRule extends AnalysisRule {
  final LintCode code;
  final String shortName;
  final String longName;
  final NamedTypeChecker _checker;

  NoFuturesRule({
    required this.code,
    required this.shortName,
    required this.longName,
  }) : _checker = NamedTypeChecker(
         longName,
         packageName: 'df_safer_dart_annotations',
       ),
       super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // df_safer_dart implements the abstractions whose @noFutures annotations
    // this rule enforces; its internals legitimately bridge Futures into the
    // safe types and must be exempt. The rule is for *consumers*.
    if (isInDfSaferDartPackage(context)) return;

    final visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addFunctionExpression(this, visitor);
  }

  void _checkBody({
    required FunctionBody body,
    required DartType? returnType,
    required AstNode errorNode,
  }) {
    if (body.isAsynchronous) {
      reportAtNode(errorNode);
    }
    if (isFutureOrFutureOr(returnType)) {
      reportAtNode(errorNode);
    }
    body.accept(_NoFuturesVisitor(this));
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final NoFuturesRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (isDirectlyAnnotatedByText(node, rule.shortName, rule.longName)) {
      rule._checkBody(
        body: node.functionExpression.body,
        returnType:
            node.functionExpression.declaredFragment?.element.returnType,
        errorNode: node,
      );
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (isDirectlyAnnotatedByText(node, rule.shortName, rule.longName)) {
      rule._checkBody(
        body: node.body,
        returnType: node.declaredFragment?.element.returnType,
        errorNode: node,
      );
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is FunctionDeclaration) return;

    final paramElement = node.correspondingParameter;
    if (paramElement != null && rule._checker.hasAnnotationOf(paramElement)) {
      rule._checkBody(
        body: node.body,
        returnType: node.declaredFragment?.element.returnType,
        errorNode: node,
      );
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _NoFuturesVisitor extends RecursiveAstVisitor<void> {
  final NoFuturesRule rule;

  int _safeContextDepth = 0;
  bool get _isInSafeContext => _safeContextDepth > 0;

  static const _asyncChecker = NamedTypeChecker(
    'Async',
    packageName: 'df_safer_dart',
  );

  static const _resolvableChecker = NamedTypeChecker(
    'Resolvable',
    packageName: 'df_safer_dart',
  );

  _NoFuturesVisitor(this.rule);

  void _check(Expression node) {
    if (_isInSafeContext) return;
    if (isFutureOrFutureOr(node.staticType)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (!_isInSafeContext) {
      rule.reportAtNode(node);
    }
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.body.isAsynchronous && !_isInSafeContext) {
      rule.reportAtNode(node.body);
    }
    if (isFutureOrFutureOr(node.declaredFragment?.element.returnType) &&
        !_isInSafeContext) {
      rule.reportAtNode(node);
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
