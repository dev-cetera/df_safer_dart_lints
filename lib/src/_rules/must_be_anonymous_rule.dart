import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// TypeChecker to identify our new annotation.
const _mustBeAnonymousChecker = TypeChecker.fromName(
  'MustBeAnonymousAnnotation',
  packageName: 'df_safer_dart_annotations',
);

class MustBeAnonymousRule extends DartLintRule {
  static const _code = LintCode(
    name: 'must_be_anonymous',
    problemMessage:
        'This parameter is annotated with @mustBeAnonymous and requires an anonymous function.',
    correctionMessage:
        'Try passing a closure like `() => yourFunction()` instead of a direct function reference.',
    errorSeverity: ErrorSeverity.ERROR, // Warning is a good default for style rules.
  );

  const MustBeAnonymousRule() : super(code: _code);

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
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
        if (_mustBeAnonymousChecker.hasAnnotationOf(parameter)) {
          // 2. If it is, check if the argument passed is NOT an anonymous function.
          // An anonymous function is an AST node of type `FunctionExpression`.
          // A named function reference (like `myFunction`) is a `SimpleIdentifier`.
          if (argument is! FunctionExpression) {
            // If it's not a FunctionExpression, it's a violation. Report it.
            reporter.atNode(argument, _code);
          }
        }
      }
    });
  }
}
