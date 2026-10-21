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

/// Rejects function arguments that cannot survive `SendPort.send`. Closures
/// and instance-method tear-offs capture state that the isolate runtime
/// cannot copy. Only top-level functions and static methods are accepted.
///
/// For non-function-typed parameters this rule is a no-op — the isolate
/// runtime enforces data sendability when `.send` actually executes.
final class SendableRule extends AnalysisRule {
  final LintCode code;
  final String shortName;
  final String longName;
  final NamedTypeChecker _checker;

  // Transitive-propagation checkers: an argument that comes from another
  // @sendable-annotated parameter is already vetted by the outer call site,
  // so it can be passed through without firing again here.
  static const _sendableChecker = NamedTypeChecker(
    'SendableAnnotation',
    packageName: 'df_safer_dart_annotations',
  );
  static const _sendableOrErrorChecker = NamedTypeChecker(
    'SendableOrErrorAnnotation',
    packageName: 'df_safer_dart_annotations',
  );

  SendableRule({
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

  /// True when [element] points to something the isolate runtime can send:
  ///
  /// 1. A top-level function (program-lifetime).
  /// 2. A static method (class-lifetime, no `this` capture).
  /// 3. A formal parameter, field, or getter whose declaration already
  ///    carries `@sendable` / `@sendableOrError` — the value's origin has
  ///    been lint-vetted, so passing it through is sound.
  static bool _isSendableFnReference(Element? element) {
    if (element == null) return false;
    if (element is TopLevelFunctionElement) return true;
    if (element is MethodElement && element.isStatic) return true;
    if (element is FormalParameterElement && _hasSendableAnnotation(element)) {
      return true;
    }
    if (element is FieldElement && _hasSendableAnnotation(element)) {
      return true;
    }
    // For a synthetic getter (`other._field`), the annotation lives on the
    // underlying field. Walk to it.
    if (element is GetterElement) {
      final variable = element.variable;
      if (variable is FieldElement && _hasSendableAnnotation(variable)) {
        return true;
      }
    }
    return false;
  }

  static bool _hasSendableAnnotation(Element element) {
    return _sendableChecker.hasAnnotationOf(element) ||
        _sendableOrErrorChecker.hasAnnotationOf(element);
  }

  static bool _isFunctionTyped(DartType type) {
    return type is FunctionType ||
        (type.alias?.element.aliasedType is FunctionType);
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class _Visitor extends SimpleAstVisitor<void> {
  final SendableRule rule;

  _Visitor(this.rule);

  @override
  void visitArgumentList(ArgumentList node) {
    for (final argument in node.arguments) {
      final parameter = argument.correspondingParameter;
      if (parameter == null) continue;
      if (!rule._checker.hasAnnotationOf(parameter)) continue;

      final inner = argument.argumentExpression;

      if (!SendableRule._isFunctionTyped(parameter.type)) continue;

      // `null` carries no captured state — always sendable.
      if (inner is NullLiteral) continue;

      if (inner is FunctionExpression) {
        rule.reportAtNode(inner);
        continue;
      }

      if (inner is Identifier) {
        final element = inner.element;
        if (SendableRule._isSendableFnReference(element)) continue;
        rule.reportAtNode(inner);
        continue;
      }

      // PropertyAccess (e.g. `Foo.bar` where `bar` is a static method) is
      // already an Identifier after resolution in most analyzer versions;
      // anything else is conservatively rejected.
      rule.reportAtNode(inner);
    }
  }
}
