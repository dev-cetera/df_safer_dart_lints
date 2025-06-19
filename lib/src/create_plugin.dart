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

import '../_common.dart';
import '_rules/_rules.g.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

PluginBase createPlugin() => _DfSaferDartLinter();

class _DfSaferDartLinter extends PluginBase {
  //
  //
  //

  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return [
      // AwaitAllFutures Rule
      AwaitAllFuturesRule(
        code: const LintCode(
          name: 'must_await_all_futures',
          problemMessage: 'Unhandled Future.',
          correctionMessage:
              'Futures in a function marked with @mustAwaitAllFutures should be handled. Try awaiting it or returning it.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        shortName: 'mustAwaitAllFutures',
        longName: 'MustAwaitAllFuturesAnnotation',
      ),
      AwaitAllFuturesRule(
        code: const LintCode(
          name: 'must_await_all_futures_or_error',
          problemMessage: 'Unhandled Future.',
          correctionMessage:
              'Futures in a function marked with @mustAwaitAllFuturesOrError must be handled. Try awaiting it or returning it.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        shortName: 'mustAwaitAllFuturesOrError',
        longName: 'MustAwaitAllFuturesOrErrorAnnotation',
      ),

      // MustBeAnonymous Rule
      MustBeAnonymousRule(
        code: const LintCode(
          name: 'must_be_anonymous',
          problemMessage: 'This parameter should receive an anonymous function.',
          correctionMessage:
              'Instead of passing a named function, pass a closure like `() { ... }`.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        shortName: 'mustBeAnonymous',
        longName: 'MustBeAnonymousAnnotation',
      ),
      MustBeAnonymousRule(
        code: const LintCode(
          name: 'must_be_anonymous_or_error',
          problemMessage: 'This parameter must receive an anonymous function.',
          correctionMessage:
              'Instead of passing a named function, pass a closure like `() { ... }`.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        shortName: 'mustBeAnonymousOrError',
        longName: 'MustBeAnonymousOrErrorAnnotation',
      ),

      // MustBeStronglyRef Rule
      MustBeStronglyRefRule(
        code: const LintCode(
          name: 'must_be_strong_ref',
          problemMessage:
              'This parameter should receive a variable, not a function literal or direct reference.',
          correctionMessage:
              'You must assign the function to a variable first, then pass the variable.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        shortName: 'mustBeStrongRef',
        longName: 'MustBeStrongRefAnnotation',
      ),
      MustBeStronglyRefRule(
        code: const LintCode(
          name: 'must_be_strong_ref_or_error',
          problemMessage:
              'This parameter should receive a variable, not a function literal or direct reference.',
          correctionMessage:
              'You must assign the function to a variable first, then pass the variable.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        shortName: 'mustBeStrongRefOrError',
        longName: 'MustBeStrongRefOrErrorAnnotation',
      ),

      // MustHandleReturn Rule
      // ignore: deprecated_member_use_from_same_package
      MustHandleReturnRule(
        code: const LintCode(
          name: 'must_handle_return',
          problemMessage: 'The return value of this function should be used.',
          correctionMessage:
              'Assign the result to a variable, use it in an expression, or await it if it\'s a Future.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        shortName: 'mustHandleReturn',
        longName: 'MustHandleReturnAnnotation',
      ),
      // ignore: deprecated_member_use_from_same_package
      MustHandleReturnRule(
        code: const LintCode(
          name: 'must_handle_return_or_error',
          problemMessage: 'The return value of this function should be used.',
          correctionMessage:
              'Assign the result to a variable, use it in an expression, or await it if it\'s a Future.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        shortName: 'mustHandleReturnOrError',
        longName: 'MustHandleReturnOrErrorAnnotation',
      ),

      // MustUseMonad Rule - WE CAN ONLY GLOBALLY ACTIVATE ONE!
      //  const MustUseMonadRule(
      //   code: LintCode(
      //     name: 'must_use_monad',
      //     problemMessage: 'The result of this Monad should be used.',
      //     correctionMessage:
      //         'Handle the Monad by assigning it to a variable, using it in a chain (e.g., `.map()`), or call `.end()` to explicitly discard the result.',
      //     errorSeverity: ErrorSeverity.WARNING,
      //   ),
      // ),
      const MustUseMonadRule(
        code: LintCode(
          name: 'must_use_monad_or_error',
          problemMessage: 'The result of this Monad must be used.',
          correctionMessage:
              'Handle the Monad by assigning it to a variable, using it in a chain (e.g., `.map()`), or call `.end()` to explicitly discard the result.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
      ),

      // NoFuturesAllowed Rule
      NoFuturesAllowedRule(
        code: const LintCode(
          name: 'no_futures_allowed',
          problemMessage: 'This function should not contain any Futures.',
          correctionMessage:
              'Refactor to remove `async`/`await` keywords and any functions that return a Future.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        shortName: 'noFuturesAllowed',
        longName: 'NoFuturesAllowedAnnotation',
      ),
      NoFuturesAllowedRule(
        code: const LintCode(
          name: 'no_futures_allowed_or_error',
          problemMessage: 'This function should not contain any Futures.',
          correctionMessage:
              'Refactor to remove `async`/`await` keywords and any functions that return a Future.',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        shortName: 'noFuturesAllowedOrError',
        longName: 'NoFuturesAllowedOrErrorAnnotation',
      ),
      MustUseUnsafeWrapperRule(
        code: const LintCode(
          name: 'must_use_unsafe_wrapper',
          problemMessage:
              'Calls to methods annotated with @unsafe must be wrapped in an UNSAFE() block.',
          correctionMessage: 'Wrap this call in UNSAFE(() => ...);',
          errorSeverity: ErrorSeverity.WARNING,
        ),
        longName: 'UnsafeAnnotation',
      ),
      MustUseUnsafeWrapperRule(
        code: const LintCode(
          name: 'must_use_unsafe_wrapper_or_error',
          problemMessage:
              'Calls to methods annotated with @unsafeOrError must be wrapped in an UNSAFE() block.',
          correctionMessage: 'Wrap this call in UNSAFE(() => ...);',
          errorSeverity: ErrorSeverity.ERROR,
        ),
        longName: 'UnsafeOrErrorAnnotation',
      ),
    ];
  }
}
