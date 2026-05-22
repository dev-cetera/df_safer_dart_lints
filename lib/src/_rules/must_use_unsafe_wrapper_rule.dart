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

final class MustUseUnsafeWrapperRule extends DartLintRule {
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  MustUseUnsafeWrapperRule({required super.code, required this.longName});

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // df_safer_dart is the package that *defines* the @unsafeOrError
    // primitives. Its own implementation legitimately calls them — flagging
    // those would force every internal Sync.okValue/Async.okValue/... to be
    // wrapped in UNSAFE(...), which adds runtime cost and visual noise for no
    // safety benefit. The rule is for *consumers*, not the implementation.
    if (context.pubspec.name == 'df_safer_dart') return;

    context.registry.addMethodInvocation((node) {
      _report(node, node.methodName.staticElement, reporter);
    });

    // Catches unsafe constructors such as `Async.ok(...)` /
    // `Resolvable.result(...)` — these are not MethodInvocations.
    context.registry.addInstanceCreationExpression((node) {
      _report(node, node.constructorName.staticElement, reporter);
    });

    // Catches unsafe getters/static fields accessed as `obj.unsafeGetter`
    // or `Class.unsafeStatic`.
    context.registry.addPropertyAccess((node) {
      _report(node, node.propertyName.staticElement, reporter);
    });

    // Catches `prefix.unsafeMember` patterns (prefixed identifier) — e.g.,
    // a static field reference, or a getter chain like
    // `obj.unsafeGetter.subProp` where the PrefixedIdentifier is the target
    // of an outer PropertyAccess. The identifier's staticElement filters out
    // non-member references (class refs, library prefixes), so this is safe.
    context.registry.addPrefixedIdentifier((node) {
      _report(node, node.identifier.staticElement, reporter);
    });
  }

  void _report(AstNode node, Element? element, ErrorReporter reporter) {
    if (element == null) return;
    // Doc-comment references (e.g. `/// See [Outcome.unwrap]`) parse into
    // (Prefixed|Simple)Identifier nodes whose parent is a CommentReference.
    // The check is O(1) — CommentReference is always the direct parent.
    if (node.parent is CommentReference) return;
    if (!_isAnnotated(element)) return;
    if (_isInsideUnsafeWrapper(node)) return;
    reporter.atNode(node, code);
  }

  bool _isAnnotated(Element element) {
    if (_checker.hasAnnotationOf(element)) return true;
    // A field-backed getter exposes its annotation on the underlying
    // VariableElement; the synthetic accessor inherits nothing, so check
    // the field too.
    if (element is PropertyAccessorElement) {
      final variable = element.variable2;
      if (variable != null && _checker.hasAnnotationOf(variable)) {
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
    final element = node.methodName.staticElement;
    if (element is! FunctionElement) return false;
    final uri = element.library.source.uri.toString();
    // Use a trailing '/' so we don't match sibling packages like
    // df_safer_dart_lints or df_safer_dart_annotations.
    return uri == 'package:df_safer_dart/df_safer_dart.dart' ||
        uri.startsWith('package:df_safer_dart/');
  }

  bool _isUnsafeLabeledStatement(AstNode node) {
    if (node is! LabeledStatement) {
      return false;
    }
    return node.labels.any((label) => label.label.name == 'UNSAFE');
  }
}
