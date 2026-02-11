## Summary

`df_safer_dart_lints` provides custom lint rules for [df_safer_dart](https://pub.dev/packages/df_safer_dart) that help enforce safety patterns at compile-time. These rules work with the [custom_lint](https://pub.dev/packages/custom_lint) package.

## Available Lint Rules

| Rule | Severity | Purpose |
|------|----------|---------|
| `must_use_outcome_or_error` | Error | Ensures `Option`/`Result`/`Resolvable` return values are handled |
| `no_future_outcome_type_or_error` | Error | Prevents `Future<Result>` types (use `Async` instead) |
| `must_await_all_futures` | Warning | Ensures Futures are awaited in annotated scopes |
| `must_await_all_futures_or_error` | Error | Same as above, but as error |
| `must_be_anonymous` | Warning | Ensures anonymous functions are passed where required |
| `must_be_anonymous_or_error` | Error | Same as above, but as error |
| `must_be_strong_ref` | Warning | Ensures strong-referenced variables are passed (for weak listener patterns) |
| `must_be_strong_ref_or_error` | Error | Same as above, but as error |
| `must_handle_return` | Warning | Ensures return values are handled |
| `must_handle_return_or_error` | Error | Same as above, but as error |
| `no_futures` | Warning | Prevents Future usage in annotated scopes |
| `no_futures_or_error` | Error | Same as above, but as error |
| `must_use_unsafe_wrapper` | Warning | Ensures unsafe calls are wrapped in `UNSAFE()` |
| `must_use_unsafe_wrapper_or_error` | Error | Same as above, but as error |

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: any
  df_safer_dart_lints: any
  df_safer_dart_annotations: any  # Optional: for annotation-based rules
```

Enable in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

# Optional: configure individual rules
custom_lint:
  rules:
    - must_use_outcome_or_error: true
    - no_future_outcome_type_or_error: true
    - must_await_all_futures: true
    - must_be_anonymous: true
    - must_use_unsafe_wrapper_or_error: true
    - no_futures: true

# Recommended: suppress warnings for UNSAFE label usage
errors:
  unused_label: ignore
  non_constant_identifier_names: ignore
```

## Usage Example

```dart
import 'package:df_safer_dart/df_safer_dart.dart';

void main() {
  // Error: must_use_outcome_or_error
  // The result must be handled
  fetchData();  // ❌ Triggers lint error

  // OK: Result is handled
  final result = fetchData();  // ✅
  result.map((data) => print(data)).end();  // ✅

  // Error: no_future_outcome_type_or_error
  // Don't use Future<Result<T>>
  Future<Result<String>> bad() async { ... }  // ❌ Use Async<String> instead
}

Async<String> fetchData() {
  return Async(() async {
    return 'data';
  });
}
```

## Related Packages

- [df_safer_dart](https://pub.dev/packages/df_safer_dart) - Core safety types (Option, Result, Resolvable)
- [df_safer_dart_annotations](https://pub.dev/packages/df_safer_dart_annotations) - Annotations for these lint rules
- [custom_lint](https://pub.dev/packages/custom_lint) - Required for running custom lints
