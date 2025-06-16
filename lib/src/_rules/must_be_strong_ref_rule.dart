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

final class MustBeStronglyRefRule extends DartLintRule {
  //
  //
  //

  final String shortName;
  final String longName;
  final String packageName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: packageName,
  );

  //
  //
  //
  MustBeStronglyRefRule({
    required super.code,
    required this.shortName,
    required this.longName,
    required this.packageName,
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
    // We inspect arguments every time a function is called.
    context.registry.addArgumentList((node) {
      for (final argument in node.arguments) {
        final parameter = argument.staticParameterElement;
        if (parameter == null) continue;

        if (_checker.hasAnnotationOf(parameter)) {
          // Violation: The argument is a function literal (e.g., `() => {}`).
          if (argument is FunctionExpression) {
            reporter.atNode(argument, code);
            continue; // Go to the next argument
          }
          // Violation: The argument is an identifier, but it points directly
          // to a function or method, not a variable.
          if (argument is Identifier) {
            final element = argument.staticElement;
            final isAllowedReference =
                element is VariableElement || element is PropertyAccessorElement;
            if (!isAllowedReference) {
              reporter.atNode(argument, code);
            }
          }
        }
      }
    });
  }
}
