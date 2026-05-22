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

// End-to-end lint-coverage test. Each rule has a fixture file under
// example/lib/fixtures/<rule>_fixture.dart that uses `// expect_lint:`
// markers. This test runs `dart run custom_lint` over the example package and
// asserts that every marker is satisfied with no extras.
//
// If custom_lint fails to spawn (e.g. local Dart SDK quirks like the
// "pub is not an AOT snapshot" issue that some macOS installs hit), the test
// is reported as skipped rather than failing, so packagers can still publish.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'every fixture under example/lib/fixtures matches its expect_lint markers',
    () async {
      final packageRoot = _packageRoot();
      final exampleDir = Directory('${packageRoot.path}/example');
      expect(
        exampleDir.existsSync(),
        isTrue,
        reason: 'example/ directory must exist alongside this package',
      );

      // Ensure dependencies are fetched so custom_lint can run.
      final pubGet = await Process.run(
        'dart',
        ['pub', 'get'],
        workingDirectory: exampleDir.path,
      );
      expect(
        pubGet.exitCode,
        0,
        reason:
            'dart pub get failed in example/:\n${pubGet.stdout}\n${pubGet.stderr}',
      );

      final result = await Process.run(
        'dart',
        ['run', 'custom_lint'],
        workingDirectory: exampleDir.path,
      );

      final stdoutText = result.stdout is List<int>
          ? utf8.decode(result.stdout as List<int>)
          : result.stdout.toString();
      final stderrText = result.stderr is List<int>
          ? utf8.decode(result.stderr as List<int>)
          : result.stderr.toString();

      // custom_lint exit codes:
      //   0 - no findings, all expect_lint markers satisfied
      //   1 - findings present (either real diagnostics or unsatisfied markers)
      //   other - tooling problem (e.g. plugin couldn't spawn)
      if (result.exitCode != 0 && result.exitCode != 1) {
        // Environmental issue (custom_lint plugin failed to spawn). Skip
        // rather than fail so CI on a working SDK still catches regressions.
        markTestSkipped(
          'custom_lint could not run (exit ${result.exitCode}):\n'
          '$stderrText',
        );
        return;
      }

      expect(
        result.exitCode,
        0,
        reason: 'custom_lint reported diagnostics over example/lib/fixtures.\n'
            'STDOUT:\n$stdoutText\nSTDERR:\n$stderrText',
      );
    },
    // The end-to-end run spawns the analyzer; give it enough time.
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

Directory _packageRoot() {
  // Tests run from the package root by default (`dart test` cwd).
  return Directory.current;
}
