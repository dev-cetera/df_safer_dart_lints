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

// ignore_for_file: deprecated_member_use

import '/_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

final class AwaitAllFuturesRule extends DartLintRule {
  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  AwaitAllFuturesRule({
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
        node.functionExpression.body.accept(
          _UnawaitedFutureVisitor(reporter: reporter, code: code),
        );
      }
    });
    context.registry.addFunctionExpression((node) {
      final paramElement = node.staticParameterElement;
      if (paramElement != null && _checker.hasAnnotationOf(paramElement)) {
        node.body.accept(
          _UnawaitedFutureVisitor(reporter: reporter, code: code),
        );
      }
    });
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _UnawaitedFutureVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final LintCode code;

  _UnawaitedFutureVisitor({required this.reporter, required this.code});

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    final expression = node.expression;
    if (_isFuture(expression.staticType)) {
      reporter.atNode(expression, code);
    }
    super.visitExpressionStatement(node);
  }

  bool _isFuture(DartType? type) {
    return type != null && (type.isDartAsyncFuture || type.isDartAsyncFutureOr);
  }
}
