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

final class AwaitAllFuturesRule extends DartLintRule {
  //
  //
  //

  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  //
  //
  //

  AwaitAllFuturesRule({
    required super.code,
    required this.shortName,
    required this.longName,
  });

  //
  //
  //

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Case 1: For named functions (like `test2`)
    context.registry.addFunctionDeclaration((node) {
      if (isDirectlyAnnotatedByText(node, shortName, longName)) {
        node.functionExpression.body.accept(
          _UnawaitedFutureVisitor(reporter: reporter, code: code),
        );
      }
    });

    // Case 2: For anonymous functions (like in `test1`)
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
  //
  //
  //

  final ErrorReporter reporter;
  final LintCode code;

  //
  //
  //

  _UnawaitedFutureVisitor({required this.reporter, required this.code});

  //
  //
  //

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    _check(node);
  }

  //
  //
  //

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    _check(node);
  }

  //
  //
  //

  void _check(Expression node) {
    if (node.staticType?.isDartAsyncFuture ?? false) {
      if (!_isHandled(node)) {
        reporter.atNode(node, code);
      }
    }
  }

  //
  //
  //

  bool _isHandled(Expression node) {
    final parent = node.parent;

    if (parent == null) return false;

    // Handled if awaited.
    if (parent is AwaitExpression) return true;

    // Handled if returned or used in a fat-arrow function.
    if (parent is ReturnStatement || parent is ExpressionFunctionBody) {
      return true;
    }

    // Handled if assigned to a variable. THIS IS THE CORRECT TYPE.
    if (parent is VariableDeclarationStatement || parent is AssignmentExpression) {
      return true;
    }

    // Handled if passed as an argument.
    if (parent is ArgumentList) return true;

    // Handled if used in a cascade.
    if (parent is CascadeExpression) return true;

    // Otherwise, it's an unhandled "fire-and-forget" call.
    return false;
  }
}
