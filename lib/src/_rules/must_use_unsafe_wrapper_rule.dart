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

// ignore_for_file: deprecated_member_use

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
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.staticElement;
      if (element == null) {
        return;
      }
      if (!_checker.hasAnnotationOf(element)) {
        return;
      }
      if (_isInsideUnsafeWrapper(node)) {
        return;
      }
      reporter.atNode(node, code);
    });
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
    return element is FunctionElement &&
        element.library.source.uri.toString().startsWith(
          'package:df_safer_dart',
        );
  }

  bool _isUnsafeLabeledStatement(AstNode node) {
    if (node is! LabeledStatement) {
      return false;
    }
    return node.labels.any((label) => label.label.name == 'UNSAFE');
  }
}
