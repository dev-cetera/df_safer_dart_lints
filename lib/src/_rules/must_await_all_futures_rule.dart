// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart' show RecursiveAstVisitor;
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

const _awaitAllFuturesChecker = TypeChecker.fromName(
  'MustAwaitAllFuturesAnnotation',
  packageName: 'df_safer_dart_annotations',
);

class AwaitAllFuturesRule extends DartLintRule {
  static const _code = LintCode(
    name: 'must_await_all_futures',
    problemMessage:
        'All Futures created inside a function marked with @mustAwaitAllFutures must be handled.',
    correctionMessage: 'Try awaiting the Future, returning it, or assigning it to a variable.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  const AwaitAllFuturesRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    // This architecture is now proven to work.

    // Case 1: For named functions (like `test2`)
    context.registry.addFunctionDeclaration((node) {
      if (_isDirectlyAnnotatedByText(node)) {
        node.functionExpression.body.accept(
          _UnawaitedFutureVisitor(reporter: reporter, code: _code),
        );
      }
    });

    // Case 2: For anonymous functions (like in `test1`)
    context.registry.addFunctionExpression((node) {
      final paramElement = node.staticParameterElement;
      if (paramElement != null && _awaitAllFuturesChecker.hasAnnotationOf(paramElement)) {
        node.body.accept(
          _UnawaitedFutureVisitor(reporter: reporter, code: _code),
        );
      }
    });
  }

  /// Checks a declaration's metadata by its source text name. This works.
  bool _isDirectlyAnnotatedByText(Declaration node) {
    for (final metadata in node.metadata) {
      final source = metadata.toSource();
      if (source.contains('mustAwaitAllFutures') ||
          source.contains('MustAwaitAllFuturesAnnotation')) {
        return true;
      }
    }
    return false;
  }
}

class _UnawaitedFutureVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final LintCode code;

  _UnawaitedFutureVisitor({required this.reporter, required this.code});

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    _check(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);
    _check(node);
  }

  void _check(Expression node) {
    if (node.staticType?.isDartAsyncFuture ?? false) {
      if (!_isHandled(node)) {
        reporter.atNode(node, code);
      }
    }
  }

  /// Determines if a Future-creating expression is properly handled.
  bool _isHandled(Expression node) {
    final parent = node.parent;

    if (parent == null) return false;

    // Handled if awaited.
    if (parent is AwaitExpression) return true;

    // Handled if returned or used in a fat-arrow function.
    if (parent is ReturnStatement || parent is ExpressionFunctionBody) return true;

    // Handled if assigned to a variable. THIS IS THE CORRECT TYPE.
    if (parent is VariableDeclarationStatement || parent is AssignmentExpression) return true;

    // Handled if passed as an argument.
    if (parent is ArgumentList) return true;

    // Handled if used in a cascade.
    if (parent is CascadeExpression) return true;

    // Otherwise, it's an unhandled "fire-and-forget" call.
    return false;
  }
}
