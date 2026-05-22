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

final class MustBeStronglyRefRule extends DartLintRule {
  final String shortName;
  final String longName;

  late final _checker = TypeChecker.fromName(
    longName,
    packageName: 'df_safer_dart_annotations',
  );

  MustBeStronglyRefRule({
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
        final parameter = argument.correspondingParameter;
        if (parameter == null) continue;

        if (!_checker.hasAnnotationOf(parameter)) continue;

        final inner =
            argument is NamedExpression ? argument.expression : argument;
        if (inner is FunctionExpression) {
          reporter.atNode(inner, code);
          continue;
        }
        if (inner is Identifier) {
          final element = inner.element;
          // Allowed strong references:
          //  * VariableElement     — `final f = ...; pass(f);`
          //  * GetterElement        — `pass(obj.f);` (stored callable read)
          //  * TopLevelFunctionElement — program-lifetime, by definition.
          //  * MethodElement on a static context — class-lifetime.
          final isAllowedReference = element is VariableElement ||
              element is GetterElement ||
              element is TopLevelFunctionElement ||
              (element is MethodElement && element.isStatic);
          if (!isAllowedReference) {
            reporter.atNode(inner, code);
          }
        }
      }
    });
  }
}
