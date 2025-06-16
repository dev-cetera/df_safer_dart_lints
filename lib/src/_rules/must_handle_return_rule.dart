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

@Deprecated('Use @useResult instead.')
final class MustHandleReturnRule extends DartLintRule {
  //
  //
  //

  final String shortName;
  final String longName;
  final String packageName;

  MustHandleReturnRule({
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
    // We register visitors for the specific AST nodes that represent calls.
    // This is more robust than listening for the general InvocationExpression.

    // Catches `myFunction()` or `myObject.myMethod()`.
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.staticElement;
      _check(node: node, element: element, reporter: reporter);
    });

    // Catches `MyClass()` or `MyClass.named()`.
    context.registry.addInstanceCreationExpression((node) {
      final element = node.constructorName.staticElement;
      _check(node: node, element: element, reporter: reporter);
    });

    // Catches `myGetter` where the getter is annotated.
    context.registry.addPrefixedIdentifier((node) {
      final element = node.staticElement;
      _check(node: node, element: element, reporter: reporter);
    });
    context.registry.addSimpleIdentifier((node) {
      // To avoid double-reporting, only check simple identifiers if they
      // aren't part of a method invocation already handled above.
      if (node.parent is MethodInvocation) return;
      final element = node.staticElement;
      _check(node: node, element: element, reporter: reporter);
    });
  }

  //
  //
  //

  /// A unified check that runs on the resolved element from any AST node.
  void _check({
    required AstNode node,
    required Element? element,
    required ErrorReporter reporter,
  }) {
    if (element is! ExecutableElement) return;

    final returnType = element.returnType;
    if (returnType is VoidType || returnType is NeverType) return;

    if (_hasMustHandleReturnAnnotation(element) && _isResultUnused(node)) {
      reporter.atNode(node, code);
    }
  }

  //
  //
  //

  bool _hasMustHandleReturnAnnotation(ExecutableElement element) {
    if (_checker.hasAnnotationOf(element)) {
      return true;
    }

    if (element is PropertyAccessorElement && element.isGetter) {
      final variable = element.variable2;
      if (variable != null && _checker.hasAnnotationOf(variable)) {
        return true;
      }
    }
    return false;
  }

  //
  //
  //

  bool _isResultUnused(AstNode node) {
    // For identifiers, we need to check the parent to see if it's an invocation.
    final nodeToCheck = node.parent is InvocationExpression
        ? node.parent!
        : node;

    var parent = nodeToCheck.parent;
    if (parent is CascadeExpression) return true;
    while (parent != null) {
      if (parent is ExpressionStatement) return true;
      if (parent is! ParenthesizedExpression && parent is! AwaitExpression) {
        return false;
      }
      parent = parent.parent;
    }
    return false;
  }
}
