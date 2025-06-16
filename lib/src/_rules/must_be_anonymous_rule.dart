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

final class MustBeAnonymousRule extends DartLintRule {
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

  MustBeAnonymousRule({
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
    // We want to inspect the arguments every time a function is called.
    // `addArgumentList` is the perfect hook for this.
    context.registry.addArgumentList((node) {
      // Iterate through each argument in the function call.
      for (final argument in node.arguments) {
        // Get the parameter that this argument corresponds to.
        final parameter = argument.staticParameterElement;
        if (parameter == null) {
          continue; // Should not happen in valid code.
        }

        // 1. Check if the parameter is annotated with @mustBeAnonymous.
        if (_checker.hasAnnotationOf(parameter)) {
          // 2. If it is, check if the argument passed is NOT an anonymous function.
          // An anonymous function is an AST node of type `FunctionExpression`.
          // A named function reference (like `myFunction`) is a `SimpleIdentifier`.
          if (argument is! FunctionExpression) {
            // If it's not a FunctionExpression, it's a violation. Report it.
            reporter.atNode(argument, code);
          }
        }
      }
    });
  }
}
