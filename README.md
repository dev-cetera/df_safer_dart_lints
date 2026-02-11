[![banner](https://github.com/dev-cetera/df_safer_dart_lints/blob/v0.3.5/doc/assets/banner.png?raw=true)](https://github.com/dev-cetera)

[![pub](https://img.shields.io/pub/v/df_safer_dart_lints.svg)](https://pub.dev/packages/df_safer_dart_lints)
[![tag](https://img.shields.io/badge/Tag-v0.3.5-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart_lints/tree/v0.3.5)
[![buymeacoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dev_cetera)
[![sponsor](https://img.shields.io/badge/Sponsor-grey?logo=github-sponsors&logoColor=pink)](https://github.com/sponsors/dev-cetera)
[![patreon](https://img.shields.io/badge/Patreon-grey?logo=patreon)](https://www.patreon.com/robelator)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

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


<!-- END _README_CONTENT -->

---

🔍 For more information, refer to the [API reference](https://pub.dev/documentation/df_safer_dart_lints/).

---

## 💬 Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### ☝️ Ways you can contribute

- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/gEQ8y2nfyX.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

### ☕ We drink a lot of coffee...

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here: https://www.buymeacoffee.com/dev_cetera

<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="40"></a>

## LICENSE

This project is released under the [MIT License](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE). See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE) for more information.
