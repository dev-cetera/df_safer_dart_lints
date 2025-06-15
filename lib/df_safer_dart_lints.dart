library;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import '/src/_must_handle_return_rule.dart';

// Plugin entrypoint
PluginBase createPlugin() => _DfSaferDartLinter();

/// The class that provides the linter rules.
class _DfSaferDartLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [MustHandleReturnRule()];
}
