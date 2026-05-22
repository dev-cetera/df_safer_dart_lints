[![pub](https://img.shields.io/pub/v/df_safer_dart_lints.svg)](https://pub.dev/packages/df_safer_dart_lints)
[![tag](https://img.shields.io/badge/Tag-v0.5.0-purple?logo=github)](https://github.com/dev-cetera/df_safer_dart_lints/tree/v0.5.0)
[![buymeacoffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/dev_cetera)
[![sponsor](https://img.shields.io/badge/Sponsor-grey?logo=github-sponsors&logoColor=pink)](https://github.com/sponsors/dev-cetera)
[![patreon](https://img.shields.io/badge/Patreon-grey?logo=patreon)](https://www.patreon.com/robelator)
[![discord](https://img.shields.io/badge/Discord-5865F2?logo=discord&logoColor=white)](https://discord.gg/gEQ8y2nfyX)
[![instagram](https://img.shields.io/badge/Instagram-E4405F?logo=instagram&logoColor=white)](https://www.instagram.com/dev_cetera/)
[![license](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart_lints/main/LICENSE)

---

## Summary

`df_safer_dart_lints` is a `custom_lint` plugin that turns the marker
annotations from
[`df_safer_dart_annotations`](https://pub.dev/packages/df_safer_dart_annotations)
into real compile-time errors. Pair it with
[`df_safer_dart`](https://pub.dev/packages/df_safer_dart) to enforce the
"no raw Futures, no try/catch, no unwrap-without-`UNSAFE`" discipline across
your entire codebase.

## Installation

```sh
dart pub add --dev custom_lint df_safer_dart_lints
# or, for a Flutter project:
flutter pub add --dev custom_lint df_safer_dart_lints
```

Enable the plugin in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

`df_safer_dart` is the practical companion (it re-exports the annotations and
provides the `UNSAFE()` wrapper), so most projects depend on it directly:

```sh
dart pub add df_safer_dart
```

## Rules

Each annotation has both a *warning* variant (the rule name without suffix)
and a *strict* variant ending in `_or_error`. Warnings let you migrate
incrementally; the `_or_error` form blocks the build.

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

Each rule has a coverage fixture under
[`example/lib/fixtures/`](https://github.com/dev-cetera/df_safer_dart_lints/tree/main/example/lib/fixtures)
and is exercised by
[`test/lint_fixtures_test.dart`](https://github.com/dev-cetera/df_safer_dart_lints/blob/main/test/lint_fixtures_test.dart),
which runs `dart run custom_lint` over the fixtures and asserts every
`expect_lint` marker is satisfied.

## Implementation notes

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
- `must_be_strong_ref` accepts top-level functions, static methods, and
  instance-method tear-offs as valid "strong" references — only inline
  function literals fire the rule.

## Running the lints

```sh
dart run custom_lint
```

This walks every Dart file in the package and reports diagnostics in plain
text. Inside an IDE that supports custom_lint (VS Code / IntelliJ with the
Dart plugin) the diagnostics appear inline with the same severity.

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
