[![pub](https://img.shields.io/pub/v/df_safer_dart_lints.svg)](https://pub.dev/packages/df_safer_dart_lints)
[![tag](https://img.shields.io/badge/Tag-v0.7.0-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart_lints/tree/v0.7.0)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE)

---

<!-- BEGIN _README_CONTENT -->

## Summary

`df_safer_dart_lints` is a Dart
[analyzer plugin](https://dart.dev/tools/analyzer-plugins) that turns the
marker annotations from
[`df_safer_dart_annotations`](https://pub.dev/packages/df_safer_dart_annotations)
into real analyzer diagnostics. Pair it with
[`df_safer_dart`](https://pub.dev/packages/df_safer_dart) to enforce the
"no raw Futures, no try/catch, no unwrap-without-`UNSAFE`" discipline across
your entire codebase.

The diagnostics appear in `dart analyze` and in your IDE, like the built-in
lints. No extra command or `custom_lint` setup is needed.

> **`flutter analyze` does not show them.** As of Flutter 3.47, `flutter
> analyze` stops as soon as the analysis server's own analysis finishes and
> does not wait for plugin diagnostics, so it reports none of this plugin's
> findings. In Flutter projects, gate CI on `dart analyze` (Flutter's bundled
> `dart`) instead; it reports everything `flutter analyze` does plus the
> plugin's diagnostics.

## Installation

Requires Dart 3.13 or newer (Flutter 3.47 or newer).

Enable the plugin in your project's `analysis_options.yaml`, under the
**top-level** `plugins:` key (not `analyzer: plugins:`):

```yaml
plugins:
  df_safer_dart_lints: ^0.6.0
```

That is all. Do **not** add `df_safer_dart_lints` to `pubspec.yaml`: the
analysis server downloads and runs the plugin in its own environment, so it
never touches your project's dependency resolution (or its `analyzer`
version). After changing the `plugins:` section, restart the analysis server
(in VS Code: *Dart: Restart Analysis Server*).

`df_safer_dart` is the practical companion (it re-exports the annotations and
provides the `UNSAFE()` wrapper), so most projects depend on it directly:

```sh
dart pub add df_safer_dart
```

### Upgrading from 0.5.x (custom_lint)

1. Remove `custom_lint` and `df_safer_dart_lints` from `dev_dependencies`.
2. Remove `- custom_lint` from `analyzer: plugins:` (and the
   `analysis_options_deprecated_plugins: ignore` workaround, if you had it).
3. Add the top-level `plugins:` block shown above.
4. Replace `dart run custom_lint` in scripts and CI with `dart analyze`
   (not `flutter analyze`, see above).
5. Prefix ignore comments with the plugin name:
   `// ignore: df_safer_dart_lints/must_use_unsafe_wrapper_or_error`
   (an unprefixed `// ignore: must_use_unsafe_wrapper_or_error` no longer
   matches plugin diagnostics).

## Configuring rules

Every rule is on by default. Turn a rule off, or change its severity, under
`diagnostics:`:

```yaml
plugins:
  df_safer_dart_lints:
    version: ^0.6.0
    diagnostics:
      must_handle_return: false      # disable
      must_be_strong_ref: error      # error | warning | info
```

Suppress a single diagnostic with the plugin-prefixed name:

```dart
// ignore: df_safer_dart_lints/must_handle_return
important();
```

`dart analyze` exits non-zero on errors, and on warnings unless
`--no-fatal-warnings` is given; add `--fatal-infos` to fail on infos too.

## Rules

Each annotation has both a *warning* variant (the rule name without suffix)
and a *strict* variant ending in `_or_error`. Warnings let you migrate
incrementally; the `_or_error` form is reported as an error.

| Lint                                              | Fires when… |
|---------------------------------------------------|-------------|
| `must_use_outcome_or_error`                       | an `Outcome` value is dropped as a bare expression statement |
| `no_future_outcome_type_or_error`                 | a type uses `Future<Outcome<T>>` or `Outcome<Future<T>>` |
| `no_futures` / `_or_error`                        | a function marked `@noFutures` contains `async`/`await` or a `Future` |
| `must_await_all_futures` / `_or_error`            | a function marked `@mustAwaitAllFutures` drops a Future as a statement |
| `must_be_anonymous` / `_or_error`                 | a parameter marked `@mustBeAnonymous` receives a named function reference |
| `must_be_strong_ref` / `_or_error`                | a parameter marked `@mustBeStrongRef` receives a function literal |
| `must_handle_return` / `_or_error`                | the return value of a function marked `@mustHandleReturn` is ignored |
| `must_use_unsafe_wrapper` / `_or_error`           | a call to a method marked `@unsafe`/`@unsafeOrError` is not wrapped in `UNSAFE(() => ...)` |
| `sendable` / `_or_error`                          | a closure or instance-method tear-off is passed to a `@sendable` function parameter |

Each rule is unit-tested under
[`test/rules/`](https://github.com/dev-cetera/df_safer_dart_lints/tree/main/test/rules),
and has a coverage fixture under
[`example/lib/fixtures/`](https://github.com/dev-cetera/df_safer_dart_lints/tree/main/example/lib/fixtures)
exercised end to end by
[`test/lint_fixtures_test.dart`](https://github.com/dev-cetera/df_safer_dart_lints/blob/main/test/lint_fixtures_test.dart),
which runs `dart analyze` over the fixtures with the plugin enabled and
asserts every `expect_lint` marker is satisfied.

## Implementation notes

- The plugin entry point is `lib/main.dart` (`final plugin = ...`). Every rule
  is registered as a *warning rule*, which the analyzer enables by default.
- The plugin matches annotations by *name* (`isDirectlyAnnotatedByText`) so
  that `@mustBeAnonymousOrError` cannot accidentally satisfy the substring
  check for `@mustBeAnonymous` — both variants run side by side without
  collisions.
- The `must_use_unsafe_wrapper` and `must_handle_return` rules explicitly
  skip identifiers that appear inside a `CommentReference` (a doc-comment
  link like `[Outcome.unwrap]`) — those are documentation, not call sites.
  The skip is an O(1) `node.parent is CommentReference` check, so the rules
  stay cheap on every analyzer pass.
- The `UNSAFE` wrapper is detected by its fully-qualified package URI
  (`package:df_safer_dart/...`), so a sibling package can't masquerade as
  `UNSAFE` to silence the rule.
- `must_be_strong_ref` accepts variables, getters, top-level functions and
  static methods as valid "strong" references; function literals, local
  functions and instance-method tear-offs fire the rule.
- `must_use_unsafe_wrapper`, `no_futures` and `no_future_outcome_type` skip
  the `df_safer_dart` package itself, which implements the primitives they
  police.

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

## 👤 Author & Contact

- Website: [robertsolves.com.au](https://robertsolves.com.au)
- Organization: [dev-cetera.com](https://dev-cetera.com)
- Email: [robert@dev-cetera.com](mailto:robert@dev-cetera.com) or [hello@robertsolves.com.au](mailto:hello@robertsolves.com.au)

## LICENSE

This project is released under the [MIT License](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE). See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE) for more information.
