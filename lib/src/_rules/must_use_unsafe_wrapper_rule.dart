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

/// Fires when a member annotated `@unsafe` / `@unsafeOrError` is used outside
/// an `UNSAFE(() => ...)` call (from `df_safer_dart`) or an `UNSAFE:` labelled
/// statement.
final class MustUseUnsafeWrapperRule extends AnalysisRule {
  final LintCode code;
  final String longName;
  final NamedTypeChecker _checker;

  MustUseUnsafeWrapperRule({required this.code, required this.longName})
    : _checker = NamedTypeChecker(
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
    // df_safer_dart is the package that *defines* the @unsafeOrError
    // primitives. Its own implementation legitimately calls them — flagging
    // those would force every internal Sync.okValue/Async.okValue/... to be
    // wrapped in UNSAFE(...), which adds runtime cost and visual noise for no
    // safety benefit. The rule is for *consumers*, not the implementation.
    if (isInDfSaferDartPackage(context)) return;

    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
    // Catches unsafe constructors such as `Async.ok(...)` /
    // `Resolvable.result(...)` — these are not MethodInvocations.
    registry.addInstanceCreationExpression(this, visitor);
    // Catches unsafe getters/static fields accessed as `obj.unsafeGetter`
    // or `Class.unsafeStatic`.
    registry.addPropertyAccess(this, visitor);
    // Catches `prefix.unsafeMember` patterns (prefixed identifier) — e.g.,
    // a static field reference, or a getter chain like
    // `obj.unsafeGetter.subProp` where the PrefixedIdentifier is the target
    // of an outer PropertyAccess. The identifier's element filters out
    // non-member references (class refs, library prefixes), so this is safe.
    registry.addPrefixedIdentifier(this, visitor);
  }

  void _report(AstNode node, Element? element) {
    if (element == null) return;
    // Doc-comment references (e.g. `/// See [Outcome.unwrap]`) parse into
    // (Prefixed|Simple)Identifier nodes whose parent is a CommentReference.
    // The check is O(1) — CommentReference is always the direct parent.
    if (node.parent is CommentReference) return;
    if (!_isAnnotated(element)) return;
    if (_isInsideUnsafeWrapper(node)) return;
    reportAtNode(node);
  }

  bool _isAnnotated(Element element) {
    if (_checker.hasAnnotationOf(element)) return true;
    // A field-backed getter exposes its annotation on the underlying
    // VariableElement; the synthetic accessor inherits nothing, so check
    // the field too.
    if (element is GetterElement) {
      if (_checker.hasAnnotationOf(element.variable)) {
        return true;
      }
    }
    return false;
  }

  bool _isInsideUnsafeWrapper(AstNode node) {
    var parent = node.parent;
    while (parent != null) {
      if (_isUnsafeFunctionCall(parent) || _isUnsafeLabeledStatement(parent)) {
        return true;
      }
      parent = parent.parent;
    }
    return false;
  }

  bool _isUnsafeFunctionCall(AstNode node) {
    if (node is! MethodInvocation || node.methodName.name != 'UNSAFE') {
      return false;
    }

    // Verify it's the top-level 'UNSAFE' function from our package.
    final element = node.methodName.element;
    if (element is! TopLevelFunctionElement) return false;
    final uri = element.library.uri.toString();
    // Use a trailing '/' so we don't match sibling packages like
    // df_safer_dart_lints or df_safer_dart_annotations.
    return uri == 'package:df_safer_dart/df_safer_dart.dart' ||
        uri.startsWith('package:df_safer_dart/');
  }

  bool _isUnsafeLabeledStatement(AstNode node) {
    if (node is! LabeledStatement) {
      return false;
    }
    return node.labels.any((label) => label.name.lexeme == 'UNSAFE');
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final MustUseUnsafeWrapperRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    rule._report(node, node.methodName.element);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    rule._report(node, node.constructorName.element);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    rule._report(node, node.propertyName.element);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    rule._report(node, node.identifier.element);
  }
}
