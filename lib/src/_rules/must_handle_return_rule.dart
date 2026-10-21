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
final class MustHandleReturnRule extends AnalysisRule {
  final LintCode code;
  final String shortName;
  final String longName;
  final NamedTypeChecker _checker;

  MustHandleReturnRule({
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
    registry.addMethodInvocation(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addPrefixedIdentifier(this, visitor);
    registry.addSimpleIdentifier(this, visitor);
  }

  void _check({required AstNode node, required Element? element}) {
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
      reportAtNode(node);
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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final MustHandleReturnRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    rule._check(node: node, element: node.methodName.element);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    rule._check(node: node, element: node.constructorName.element);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    rule._check(node: node, element: node.element);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.parent is MethodInvocation) return;
    rule._check(node: node, element: node.element);
  }
}
