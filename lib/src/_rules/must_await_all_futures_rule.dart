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

/// Fires when a function or method annotated `@mustAwaitAllFutures` /
/// `@mustAwaitAllFuturesOrError` (or a function literal passed to a parameter
/// with that annotation) drops a `Future` as a bare expression statement.
final class AwaitAllFuturesRule extends AnalysisRule {
  final LintCode code;
  final String shortName;
  final String longName;
  final NamedTypeChecker _checker;

  AwaitAllFuturesRule({
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
    final visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addFunctionExpression(this, visitor);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final AwaitAllFuturesRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (isDirectlyAnnotatedByText(node, rule.shortName, rule.longName)) {
      node.functionExpression.body.accept(_UnawaitedFutureVisitor(rule));
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (isDirectlyAnnotatedByText(node, rule.shortName, rule.longName)) {
      node.body.accept(_UnawaitedFutureVisitor(rule));
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    final paramElement = node.correspondingParameter;
    if (paramElement != null && rule._checker.hasAnnotationOf(paramElement)) {
      node.body.accept(_UnawaitedFutureVisitor(rule));
    }
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _UnawaitedFutureVisitor extends RecursiveAstVisitor<void> {
  final AwaitAllFuturesRule rule;

  _UnawaitedFutureVisitor(this.rule);

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final expression = node.expression;
    if (isFutureOrFutureOr(expression.staticType)) {
      rule.reportAtNode(expression);
    }
    super.visitExpressionStatement(node);
  }
}
