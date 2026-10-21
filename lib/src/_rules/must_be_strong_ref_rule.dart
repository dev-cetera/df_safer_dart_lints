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

/// Fires when a parameter annotated `@mustBeStrongRef` /
/// `@mustBeStrongRefOrError` receives a function literal or a reference that
/// does not outlive the call (a local function or an instance-method
/// tear-off).
final class MustBeStronglyRefRule extends AnalysisRule {
  final LintCode code;
  final String shortName;
  final String longName;
  final NamedTypeChecker _checker;

  MustBeStronglyRefRule({
    required this.code,
    required this.shortName,
    required this.longName,
  }) : _checker = NamedTypeChecker(
         longName,
         packageName: 'df_safer_dart_annotations',
       ),
       super(name: code.lowerCaseName, description: code.problemMessage);

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addArgumentList(this, _Visitor(this));
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final MustBeStronglyRefRule rule;

  _Visitor(this.rule);

  @override
  void visitArgumentList(ArgumentList node) {
    for (final argument in node.arguments) {
      final parameter = argument.correspondingParameter;
      if (parameter == null) continue;

      if (!rule._checker.hasAnnotationOf(parameter)) continue;

      final inner = argument.argumentExpression;
      if (inner is FunctionExpression) {
        rule.reportAtNode(inner);
        continue;
      }
      if (inner is Identifier) {
        final element = inner.element;
        // Allowed strong references:
        //  * VariableElement     — `final f = ...; pass(f);`
        //  * GetterElement        — `pass(obj.f);` (stored callable read)
        //  * TopLevelFunctionElement — program-lifetime, by definition.
        //  * MethodElement on a static context — class-lifetime.
        final isAllowedReference =
            element is VariableElement ||
            element is GetterElement ||
            element is TopLevelFunctionElement ||
            (element is MethodElement && element.isStatic);
        if (!isAllowedReference) {
          rule.reportAtNode(inner);
        }
      }
    }
  }
}
