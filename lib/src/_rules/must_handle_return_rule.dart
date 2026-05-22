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

/// Fires when a function or method annotated `@mustHandleReturn` /
/// `@mustHandleReturnOrError` has its return value discarded.
///
/// Dart's built-in `@useResult` (from `package:meta`) covers most cases.
/// Prefer it for new code; this rule remains so that existing annotated APIs
/// keep working alongside the other safer-dart rules.
final class MustHandleReturnRule extends DartLintRule {
  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  MustHandleReturnRule({
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
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.element;
      _check(node: node, element: element, reporter: reporter);
    });

    context.registry.addInstanceCreationExpression((node) {
      final element = node.constructorName.element;
      _check(node: node, element: element, reporter: reporter);
    });

    context.registry.addPrefixedIdentifier((node) {
      final element = node.element;
      _check(node: node, element: element, reporter: reporter);
    });
    context.registry.addSimpleIdentifier((node) {
      if (node.parent is MethodInvocation) return;
      final element = node.element;
      _check(node: node, element: element, reporter: reporter);
    });
  }

  void _check({
    required AstNode node,
    required Element? element,
    required ErrorReporter reporter,
  }) {
    if (element is! ExecutableElement) return;
    // Doc-comment references like `/// See [foo]` parse as identifiers whose
    // direct parent is a CommentReference. O(1) skip.
    if (node.parent is CommentReference) return;

    final returnType = element.returnType;
    if (returnType is VoidType || returnType is NeverType) return;

    // Order matters for perf — this visitor fires on every identifier in the
    // file. `_isResultUnused` is a short parent walk; the annotation check
    // iterates element.metadata. Filter on the cheap check first so the
    // metadata walk only runs for the small subset of calls whose result is
    // actually being dropped.
    if (!_isResultUnused(node)) return;
    if (_hasMustHandleReturnAnnotation(element)) {
      reporter.atNode(node, code);
    }
  }

  bool _hasMustHandleReturnAnnotation(ExecutableElement element) {
    if (_checker.hasAnnotationOf(element)) {
      return true;
    }

    if (element is GetterElement) {
      final variable = element.variable;
      if (_checker.hasAnnotationOf(variable)) {
        return true;
      }
    }
    return false;
  }

  bool _isResultUnused(AstNode node) {
    final nodeToCheck =
        node.parent is InvocationExpression ? node.parent! : node;
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
