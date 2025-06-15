// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart' show VoidType, NeverType;
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// The TypeChecker is the robust way to check for an annotation.
const _annotationChecker = TypeChecker.fromName(
  'MustHandleReturn', // The class name of the annotation
  packageName: 'df_safer_dart', // The package where it's defined
);

class MustHandleReturnRule extends DartLintRule {
  static const _code = LintCode(
    name: 'must_handle_return',
    problemMessage: 'The return value of a function annotated with @mustHandleReturn must be used.',
    correctionMessage: 'Assign the result to a variable, or use it in an expression.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  MustHandleReturnRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInvocationExpression((node) {
      // Use the stable `.element` getter.
      final element = node.staticInvokeType?.element;

      if (element is! ExecutableElement) return;

      final returnType = element.returnType;
      // This is the correct, modern way to check for these types.
      if (returnType is VoidType || returnType is NeverType) return;

      if (_hasMustHandleReturnAnnotation(element) && _isResultUnused(node)) {
        reporter.atNode(node, _code);
      }
    });
  }

  /// Checks if the given [Element] has the `@mustHandleReturn` annotation.
  bool _hasMustHandleReturnAnnotation(ExecutableElement element) {
    // First, check for an annotation directly on the function/method.
    if (_annotationChecker.hasAnnotationOf(element)) {
      return true;
    }

    // If the element is a getter, the annotation is on its corresponding
    // variable, not on the getter itself.
    if (element is PropertyAccessorElement && element.isGetter) {
      // Use the modern `.variable2` property and handle its nullability.
      final variable = element.variable2;
      if (variable != null && _annotationChecker.hasAnnotationOf(variable)) {
        return true;
      }
    }

    return false;
  }

  /// Determines if the result of an invocation is "unused".
  bool _isResultUnused(InvocationExpression node) {
    var parent = node.parent;

    if (parent is CascadeExpression) return true;

    while (parent != null) {
      if (parent is ExpressionStatement) return true;
      if (parent is! ParenthesizedExpression && parent is! AwaitExpression) return false;
      parent = parent.parent;
    }
    return false;
  }
}
