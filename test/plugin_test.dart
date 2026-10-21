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

import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/error/error.dart';
import 'package:df_safer_dart_lints/df_safer_dart_lints.dart';
import 'package:test/test.dart';

// Pins the rule catalogue: names, severities and how the plugin registers
// them. Consumers configure rules by these names, so a rename is breaking.

void main() {
  const expectedSeverities = {
    'must_use_outcome_or_error': DiagnosticSeverity.ERROR,
    'no_future_outcome_type_or_error': DiagnosticSeverity.ERROR,
    'must_await_all_futures': DiagnosticSeverity.WARNING,
    'must_await_all_futures_or_error': DiagnosticSeverity.ERROR,
    'must_be_anonymous': DiagnosticSeverity.WARNING,
    'must_be_anonymous_or_error': DiagnosticSeverity.ERROR,
    'must_be_strong_ref': DiagnosticSeverity.WARNING,
    'must_be_strong_ref_or_error': DiagnosticSeverity.ERROR,
    'must_handle_return': DiagnosticSeverity.WARNING,
    'must_handle_return_or_error': DiagnosticSeverity.ERROR,
    'no_futures': DiagnosticSeverity.WARNING,
    'no_futures_or_error': DiagnosticSeverity.ERROR,
    'must_use_unsafe_wrapper': DiagnosticSeverity.WARNING,
    'must_use_unsafe_wrapper_or_error': DiagnosticSeverity.ERROR,
    'sendable': DiagnosticSeverity.WARNING,
    'sendable_or_error': DiagnosticSeverity.ERROR,
  };

  test('every rule has its expected name, code and severity', () {
    final rules = createDfSaferDartRules();
    expect(
      {for (final rule in rules) rule.name: rule.diagnosticCode.severity},
      expectedSeverities,
    );
    for (final rule in rules) {
      expect(rule.diagnosticCode.lowerCaseName, rule.name);
    }
  });

  test('the plugin registers every rule as an on-by-default warning rule', () {
    final registry = _RecordingRegistry();
    final plugin = DfSaferDartLintsPlugin();
    plugin.register(registry);
    expect(plugin.name, 'df_safer_dart_lints');
    expect(registry.lintRules, isEmpty);
    expect(registry.warningRules, unorderedEquals(expectedSeverities.keys));
  });
}

/// Records what [DfSaferDartLintsPlugin.register] registers.
///
/// Only the two rule-registration methods are implemented: a call to anything
/// else (fixes, assists) fails the test through [noSuchMethod].
class _RecordingRegistry implements PluginRegistry {
  final lintRules = <String>[];
  final warningRules = <String>[];

  @override
  void registerLintRule(AbstractAnalysisRule rule) => lintRules.add(rule.name);

  @override
  void registerWarningRule(AbstractAnalysisRule rule) {
    warningRules.add(rule.name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
