import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// TypeChecker to identify our new annotation.
const _mustBeStronglyReferencedChecker = TypeChecker.fromName(
  'MustBeStrongRefAnnotation',
  packageName: 'df_safer_dart_annotations',
);

class MustBeStronglyRefRule extends DartLintRule {
  static const _code = LintCode(
    name: 'must_be_strong_ref',
    problemMessage: 'This parameter requires a variable that references a function.',
    correctionMessage: 'Assign the function to a variable first, then pass the variable.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  const MustBeStronglyRefRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    // We inspect arguments every time a function is called.
    context.registry.addArgumentList((node) {
      for (final argument in node.arguments) {
        final parameter = argument.staticParameterElement;
        if (parameter == null) continue;

        // 1. Check if the parameter is annotated.
        if (_mustBeStronglyReferencedChecker.hasAnnotationOf(parameter)) {
          // 2. Check for violations.

          // Violation: The argument is a function literal (e.g., `() => {}`).
          if (argument is FunctionExpression) {
            reporter.atNode(argument, _code);
            continue;
          }

          // Violation: The argument is an identifier, but it points directly
          // to a function or method, not a variable.
          if (argument is Identifier) {
            final element = argument.staticElement;

            // `VariableElement` is the superclass for local variables, parameters,
            // fields, and top-level variables. This is the "allowed" category.
            // If the element is anything else (like a FunctionElement or MethodElement),
            // it's a violation.
            if (element is! VariableElement) {
              reporter.atNode(argument, _code);
            }
          }
        }
      }
    });
  }
}
