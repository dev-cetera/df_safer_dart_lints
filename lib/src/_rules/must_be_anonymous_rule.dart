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
  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  MustBeAnonymousRule({
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
    context.registry.addArgumentList((node) {
      for (final argument in node.arguments) {
        final parameter = argument.staticParameterElement;
        if (parameter == null) {
          continue;
        }
        if (_checker.hasAnnotationOf(parameter)) {
          if (argument is! FunctionExpression) {
            reporter.atNode(argument, code);
          }
        }
      }
    });
  }
}
