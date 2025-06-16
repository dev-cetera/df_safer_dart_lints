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

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart' show VoidType, NeverType;
import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class MustUseMonadRule extends DartLintRule {
  //
  //
  //

  static const _monadChecker = TypeChecker.fromName(
    'Monad',
    packageName: 'df_safer_dart',
  );

  //
  //
  //

  static const _code = LintCode(
    name: 'must_use_monad',
    problemMessage: 'The value of a Monad (Result, Option, etc.) must be used.',
    correctionMessage:
        'Try assigning the result to a variable or calling a method on it or use the .end() method if you are sure you don\'t need the result.',
    errorSeverity: ErrorSeverity.ERROR,
  );

  //
  //
  //

  const MustUseMonadRule() : super(code: _code);

  //
  //

  //
  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addExpressionStatement((node) {
      final expression = node.expression;

      if (expression is AssignmentExpression) {
        return;
      }
      final type = expression.staticType;
      if (type == null || type is VoidType || type is NeverType) {
        return;
      }
      if (_monadChecker.isSuperTypeOf(type)) {
        reporter.atNode(expression, _code);
      }
    });
  }
}
