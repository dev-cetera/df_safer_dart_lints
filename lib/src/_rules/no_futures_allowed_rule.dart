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

final class NoFuturesAllowedRule extends DartLintRule {
  //
  //
  //

  final String shortName;
  final String longName;
  final String packageName;

  NoFuturesAllowedRule({
    required super.code,
    required this.shortName,
    required this.longName,
    required this.packageName,
  });

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: packageName,
  );

  //
  //
  //

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Case 1: For named functions (top-level, methods, local functions)
    context.registry.addFunctionDeclaration((node) {
      if (isDirectlyAnnotatedByText(
        node,
        shortName,
        longName,
      )) {
        // Perform signature and body checks.
        _checkFunction(node.functionExpression, reporter, node);
      }
    });

    // Case 2: For anonymous functions passed as arguments
    context.registry.addFunctionExpression((node) {
      final paramElement = node.staticParameterElement;
      if (paramElement != null && _checker.hasAnnotationOf(paramElement)) {
        // Perform signature and body checks.
        _checkFunction(node, reporter, node);
      }
    });
  }

  /// Performs all checks for a given function.
  void _checkFunction(FunctionExpression node, ErrorReporter reporter, AstNode errorNode) {
    // 1. Check for `async` keyword. This is the correct way.
    if (node.body.isAsynchronous) {
      reporter.atNode(errorNode, code);
    }

    // 2. Check the function's return type.
    final returnType = node.declaredElement?.returnType;
    if (returnType != null && returnType.isDartAsyncFuture) {
      reporter.atNode(errorNode, code);
    }

    // 3. Visit the function body to find any other Future usage.
    node.body.accept(_NoFuturesVisitor(reporter: reporter, code: code));
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _NoFuturesVisitor extends RecursiveAstVisitor<void> {
  //
  //
  //

  final ErrorReporter reporter;
  final LintCode code;

  //
  //
  //

  _NoFuturesVisitor({
    required this.reporter,
    required this.code,
  });

  //
  //
  //

  @override
  void visitAwaitExpression(AwaitExpression node) {
    // Violation: The `await` keyword is used.
    reporter.atNode(
      node,
      code,
    );
    super.visitAwaitExpression(node);
  }

  //
  //
  //

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Violation: A method is called that returns a Future.
    _check(node);
    super.visitMethodInvocation(node);
  }

  //
  //
  //

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Violation: An object is instantiated that is a Future.
    _check(node);
    super.visitInstanceCreationExpression(node);
  }

  //
  //
  //

  void _check(Expression node) {
    // If any expression's type is a Future, it's a violation.
    if (node.staticType?.isDartAsyncFuture ?? false) {
      reporter.atNode(node, code);
    }
  }
}
