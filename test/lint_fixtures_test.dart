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

// End-to-end coverage test. Each rule has a fixture file under
// example/lib/fixtures/<rule>_fixture.dart that uses `// expect_lint:`
// markers (see example/lib/fixtures/_README.md). This test runs
// `dart analyze --format=machine` in example/, whose analysis_options.yaml
// loads this checkout as an analyzer plugin, and checks that the plugin's
// diagnostics match the markers exactly, line by line.
//
// It exercises the real plugin path: the analysis server resolves the plugin
// package, starts it, and reports its diagnostics through `dart analyze`.

import 'dart:io';

import 'package:df_safer_dart_lints/df_safer_dart_lints.dart';
import 'package:test/test.dart';

void main() {
  test(
    'every expect_lint marker under example/lib matches the plugin output',
    () async {
      final exampleDir = Directory('${Directory.current.path}/example');
      expect(
        exampleDir.existsSync(),
        isTrue,
        reason: 'example/ directory must exist alongside this package',
      );

      final pubGet = await Process.run(
        Platform.resolvedExecutable,
        ['pub', 'get'],
        workingDirectory: exampleDir.path,
      );
      expect(
        pubGet.exitCode,
        0,
        reason:
            'dart pub get failed in example/:\n${pubGet.stdout}\n${pubGet.stderr}',
      );

      final analyze = await Process.run(
        Platform.resolvedExecutable,
        ['analyze', '--format=machine', '.'],
        workingDirectory: exampleDir.path,
      );
      final stderrText = analyze.stderr.toString();
      // An exception inside a rule surfaces on stderr and silently drops
      // every diagnostic of the plugin for that library.
      expect(
        stderrText,
        isNot(contains('An unexpected error was encountered')),
        reason: 'the plugin crashed:\n$stderrText',
      );

      final ruleNames = {
        for (final rule in createDfSaferDartRules()) rule.name,
      };
      final actual = _actualLints(
        '${analyze.stdout}$stderrText',
        ruleNames,
      );
      final expected = _expectedLints(
        Directory('${exampleDir.path}/lib'),
        ruleNames,
      );

      expect(
        expected,
        isNotEmpty,
        reason: 'no expect_lint markers found',
      );
      expect(
        actual,
        expected,
        reason:
            'plugin diagnostics (file:line -> rules) differ from the markers.\n'
            'dart analyze output:\n${analyze.stdout}\n$stderrText',
      );
    },
    // The first run resolves the plugin's own dependencies; give it time.
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

/// Parses `dart analyze --format=machine` output into
/// `file:line -> {rule names}` for this plugin's rules only.
Map<String, Set<String>> _actualLints(String output, Set<String> ruleNames) {
  final result = <String, Set<String>>{};
  for (final line in output.split('\n')) {
    // SEVERITY|TYPE|CODE|FILE|LINE|COLUMN|LENGTH|MESSAGE
    final fields = line.split('|');
    if (fields.length < 8) continue;
    final code = fields[2].toLowerCase();
    if (!ruleNames.contains(code)) continue;
    final key = '${File(fields[3]).absolute.path}:${fields[4]}';
    (result[key] ??= <String>{}).add(code);
  }
  return result;
}

/// Collects `// expect_lint: a, b` markers as `file:line -> {a, b}`, keyed by
/// the line that follows the marker.
Map<String, Set<String>> _expectedLints(Directory lib, Set<String> ruleNames) {
  final marker = RegExp(r'^\s*// expect_lint:\s*(.+)$');
  final result = <String, Set<String>>{};
  final files = lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  for (final file in files) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final match = marker.firstMatch(lines[i]);
      if (match == null) continue;
      final names = match.group(1)!.split(',').map((name) => name.trim());
      for (final name in names) {
        if (!ruleNames.contains(name)) {
          throw StateError('${file.path}:${i + 1}: unknown rule `$name`');
        }
      }
      // Line numbers are 1-based; the marker covers the next line.
      final key = '${file.absolute.path}:${i + 2}';
      (result[key] ??= <String>{}).addAll(names);
    }
  }
  return result;
}
