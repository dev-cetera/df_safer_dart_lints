import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart' show RecursiveAstVisitor;
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// TypeChecker to identify our new annotation.
const _noFuturesAllowedChecker = TypeChecker.fromName(
  'NoFuturesAllowedAnnotation',
  packageName: 'df_safer_dart_annotations',
);

class NoFuturesAllowedRule extends DartLintRule {
  static const _code = LintCode(
    name: 'no_futures_allowed',
    problemMessage: 'Futures are not allowed in a function marked with @noFuturesAllowed.',
    correctionMessage: 'Remove any async/await keywords and do not create or return Futures.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  const NoFuturesAllowedRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    // Case 1: For named functions (top-level, methods, local functions)
    context.registry.addFunctionDeclaration((node) {
      if (_isDirectlyAnnotatedByText(node)) {
        // Perform signature and body checks.
        _checkFunction(node.functionExpression, reporter, node);
      }
    });

    // Case 2: For anonymous functions passed as arguments
    context.registry.addFunctionExpression((node) {
      final paramElement = node.staticParameterElement;
      if (paramElement != null && _noFuturesAllowedChecker.hasAnnotationOf(paramElement)) {
        // Perform signature and body checks.
        _checkFunction(node, reporter, node);
      }
    });
  }

  /// Performs all checks for a given function.
  void _checkFunction(FunctionExpression node, ErrorReporter reporter, AstNode errorNode) {
    // 1. Check for `async` keyword. This is the correct way.
    if (node.body.isAsynchronous) {
      reporter.atNode(
        errorNode,
        _code,
      );
    }

    // 2. Check the function's return type.
    final returnType = node.declaredElement?.returnType;
    if (returnType != null && returnType.isDartAsyncFuture) {
      reporter.atNode(
        errorNode,
        _code,
      );
    }

    // 3. Visit the function body to find any other Future usage.
    node.body.accept(_NoFuturesVisitor(reporter: reporter, code: _code));
  }

  /// Checks a declaration's metadata by its source text name.
  bool _isDirectlyAnnotatedByText(Declaration node) {
    for (final metadata in node.metadata) {
      final source = metadata.toSource();
      if (source.contains('noFuturesAllowed') || source.contains('NoFuturesAllowedAnnotation')) {
        return true;
      }
    }
    return false;
  }
}

/// A visitor that finds any trace of a Future within a function body.
class _NoFuturesVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final LintCode code;

  _NoFuturesVisitor({required this.reporter, required this.code});

  @override
  void visitAwaitExpression(AwaitExpression node) {
    // Violation: The `await` keyword is used.
    reporter.atNode(
      node,
      code,
    );
    super.visitAwaitExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Violation: A method is called that returns a Future.
    _check(node);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Violation: An object is instantiated that is a Future.
    _check(node);
    super.visitInstanceCreationExpression(node);
  }

  void _check(Expression node) {
    // If any expression's type is a Future, it's a violation.
    if (node.staticType?.isDartAsyncFuture ?? false) {
      reporter.atNode(node, code);
    }
  }
}
