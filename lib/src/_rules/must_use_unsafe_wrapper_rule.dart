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

final class MustUseUnsafeWrapperRule extends DartLintRule {
  //
  //
  //

  final String shortName;
  final String longName;
  final String packageName;
  final String unsafeWrapperName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: packageName,
  );

  //
  //
  //

  MustUseUnsafeWrapperRule({
    required super.code,
    required this.shortName,
    required this.longName,
    required this.packageName,
    required this.unsafeWrapperName,
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
    context.registry.addMethodInvocation((node) {
      final element = node.methodName.staticElement;
      if (element == null) {
        return;
      }
      if (!_checker.hasAnnotationOf(element)) {
        return;
      }
      if (_isInsideUnsafeWraooer(node)) {
        return;
      }
      reporter.atNode(node, code);
    });
  }

  //
  //
  //

  bool _isInsideUnsafeWraooer(AstNode node) {
    var parent = node.parent;
    while (parent != null) {
      if (parent is MethodInvocation && parent.methodName.name == unsafeWrapperName) {
        final element = parent.methodName.staticElement;
        // Verify it's the top-level 'unsafe' function from our package.
        if (element is FunctionElement &&
            element.library.source.uri.toString().startsWith('package:$packageName')) {
          return true;
        }
      }
      parent = parent.parent;
    }
    return false;
  }
}
