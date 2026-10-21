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

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import '../_common.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// The `df_safer_dart_lints` analyzer plugin.
///
/// The analysis server loads it through the top-level `plugin` variable in
/// `lib/main.dart` when a project lists `df_safer_dart_lints` under the
/// top-level `plugins:` key of its `analysis_options.yaml`.
///
/// Every rule is registered as a *warning rule*, which the analyzer enables
/// by default. That keeps the behaviour of the old `custom_lint` plugin:
/// enabling the plugin turns every rule on, and a project opts a rule out by
/// setting it to `false` under `plugins: df_safer_dart_lints: diagnostics:`.
/// (A *lint rule* would instead be off until a project opted it in.)
final class DfSaferDartLintsPlugin extends Plugin {
  @override
  String get name => 'df_safer_dart_lints';

  @override
  void register(PluginRegistry registry) {
    for (final rule in createDfSaferDartRules()) {
      registry.registerWarningRule(rule);
    }
  }
}

/// Creates one instance of every rule this plugin provides.
///
/// Each annotation has a warning-severity rule and an error-severity
/// `_or_error` twin, so each twin is its own rule and can be configured on
/// its own.
List<AnalysisRule> createDfSaferDartRules() {
  return [
    MustUseOutcomeRule(
      code: const LintCode(
        'must_use_outcome_or_error',
        'The result of this Outcome must be used.',
        correctionMessage: 'Handle the Outcome by assigning it to a variable, using it in a chain (e.g., `.map()`), or call `.end()` to explicitly discard the result.',
        severity: DiagnosticSeverity.ERROR,
      ),
    ),

    NoFutureOutcomeTypeRule(
      code: const LintCode(
        'no_future_outcome_type_or_error',
        'Avoid using Future/FutureOr Outcome types. This can lead to unhandled errors and confusing type hierarchies.',
        correctionMessage: 'Use `Resolvable`, `Async`, or `.toResolvable()` to represent asynchronous operations that return a Outcome.',
        severity: DiagnosticSeverity.ERROR,
      ),
    ),

    // AwaitAllFutures Rule
    AwaitAllFuturesRule(
      code: const LintCode(
        'must_await_all_futures',
        'Unhandled Future.',
        correctionMessage: 'Futures in a function marked with @mustAwaitAllFutures should be handled. Try awaiting it or returning it.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'mustAwaitAllFutures',
      longName: 'MustAwaitAllFuturesAnnotation',
    ),
    AwaitAllFuturesRule(
      code: const LintCode(
        'must_await_all_futures_or_error',
        'Unhandled Future.',
        correctionMessage: 'Futures in a function marked with @mustAwaitAllFuturesOrError must be handled. Try awaiting it or returning it.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'mustAwaitAllFuturesOrError',
      longName: 'MustAwaitAllFuturesOrErrorAnnotation',
    ),

    // MustBeAnonymous Rule
    MustBeAnonymousRule(
      code: const LintCode(
        'must_be_anonymous',
        'This parameter should receive an anonymous function.',
        correctionMessage: 'Instead of passing a named function, pass a closure like `() { ... }`.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'mustBeAnonymous',
      longName: 'MustBeAnonymousAnnotation',
    ),
    MustBeAnonymousRule(
      code: const LintCode(
        'must_be_anonymous_or_error',
        'This parameter must receive an anonymous function.',
        correctionMessage: 'Instead of passing a named function, pass a closure like `() { ... }`.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'mustBeAnonymousOrError',
      longName: 'MustBeAnonymousOrErrorAnnotation',
    ),

    // MustBeStronglyRef Rule
    MustBeStronglyRefRule(
      code: const LintCode(
        'must_be_strong_ref',
        'This parameter should receive a variable, not a function literal or direct reference.',
        correctionMessage: 'You must assign the function to a variable first, then pass the variable.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'mustBeStrongRef',
      longName: 'MustBeStrongRefAnnotation',
    ),
    MustBeStronglyRefRule(
      code: const LintCode(
        'must_be_strong_ref_or_error',
        'This parameter should receive a variable, not a function literal or direct reference.',
        correctionMessage: 'You must assign the function to a variable first, then pass the variable.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'mustBeStrongRefOrError',
      longName: 'MustBeStrongRefOrErrorAnnotation',
    ),

    // MustHandleReturn Rule
    MustHandleReturnRule(
      code: const LintCode(
        'must_handle_return',
        'The return value of this function should be used.',
        correctionMessage: 'Assign the result to a variable, use it in an expression, or await it if it\'s a Future.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'mustHandleReturn',
      longName: 'MustHandleReturnAnnotation',
    ),
    MustHandleReturnRule(
      code: const LintCode(
        'must_handle_return_or_error',
        'The return value of this function should be used.',
        correctionMessage: 'Assign the result to a variable, use it in an expression, or await it if it\'s a Future.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'mustHandleReturnOrError',
      longName: 'MustHandleReturnOrErrorAnnotation',
    ),

    // NoFuturesAllowed Rule
    NoFuturesRule(
      code: const LintCode(
        'no_futures',
        'Your function should not contain any Futures.',
        correctionMessage: 'Refactor to remove `async`/`await` keywords and any functions that return a Future.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'noFutures',
      longName: 'NoFuturesAnnotation',
    ),
    NoFuturesRule(
      code: const LintCode(
        'no_futures_or_error',
        'Your function should not contain any Futures.',
        correctionMessage: 'Refactor to remove `async`/`await` keywords and any functions that return a Future.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'noFuturesOrError',
      longName: 'NoFuturesOrErrorAnnotation',
    ),
    MustUseUnsafeWrapperRule(
      code: const LintCode(
        'must_use_unsafe_wrapper',
        'Calls to methods annotated with @unsafe must be wrapped in an UNSAFE() block.',
        correctionMessage: 'Wrap this call in UNSAFE(() => ...);',
        severity: DiagnosticSeverity.WARNING,
      ),
      longName: 'UnsafeAnnotation',
    ),
    MustUseUnsafeWrapperRule(
      code: const LintCode(
        'must_use_unsafe_wrapper_or_error',
        'Calls to methods annotated with @unsafeOrError must be wrapped in an UNSAFE() block.',
        correctionMessage: 'Wrap this call in UNSAFE(() => ...);',
        severity: DiagnosticSeverity.ERROR,
      ),
      longName: 'UnsafeOrErrorAnnotation',
    ),

    // Sendable Rule
    SendableRule(
      code: const LintCode(
        'sendable',
        'This argument is not sendable through SendPort. Closures and instance-method tear-offs cannot cross isolate boundaries.',
        correctionMessage: 'Pass a top-level function or a static method reference instead of a closure.',
        severity: DiagnosticSeverity.WARNING,
      ),
      shortName: 'sendable',
      longName: 'SendableAnnotation',
    ),
    SendableRule(
      code: const LintCode(
        'sendable_or_error',
        'This argument is not sendable through SendPort. Closures and instance-method tear-offs cannot cross isolate boundaries.',
        correctionMessage: 'Pass a top-level function or a static method reference instead of a closure.',
        severity: DiagnosticSeverity.ERROR,
      ),
      shortName: 'sendableOrError',
      longName: 'SendableOrErrorAnnotation',
    ),
  ];
}
