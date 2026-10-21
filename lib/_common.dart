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

export '/src/_src.g.dart';
export '/src/_rules/_rules.g.dart';

export 'package:analyzer/analysis_rule/analysis_rule.dart' show AnalysisRule;
export 'package:analyzer/analysis_rule/rule_context.dart' show RuleContext;
export 'package:analyzer/analysis_rule/rule_visitor_registry.dart'
    show RuleVisitorRegistry;
export 'package:analyzer/dart/ast/ast.dart';
export 'package:analyzer/dart/ast/visitor.dart'
    show RecursiveAstVisitor, SimpleAstVisitor;
export 'package:analyzer/dart/element/element.dart';
export 'package:analyzer/dart/element/type.dart';
export 'package:analyzer/error/error.dart'
    show DiagnosticCode, DiagnosticSeverity, LintCode;
