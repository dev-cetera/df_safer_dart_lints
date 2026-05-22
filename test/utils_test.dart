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

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:df_safer_dart_lints/df_safer_dart_lints.dart';
import 'package:test/test.dart';

FunctionDeclaration _parseFirstFunction(String source) {
  final result = parseString(
    content: source,
    featureSet: FeatureSet.latestLanguageVersion(),
    throwIfDiagnostics: false,
  );
  for (final declaration in result.unit.declarations) {
    if (declaration is FunctionDeclaration) return declaration;
  }
  throw StateError('No FunctionDeclaration found in source');
}

MethodDeclaration _parseFirstMethod(String source) {
  final result = parseString(
    content: source,
    featureSet: FeatureSet.latestLanguageVersion(),
    throwIfDiagnostics: false,
  );
  for (final declaration in result.unit.declarations) {
    if (declaration is ClassDeclaration) {
      for (final member in declaration.members) {
        if (member is MethodDeclaration) return member;
      }
    }
  }
  throw StateError('No MethodDeclaration found in source');
}

void main() {
  group('isDirectlyAnnotatedByText', () {
    test('matches an exact short-name annotation', () {
      final fn = _parseFirstFunction('@mustBeAnonymous\nvoid foo() {}');
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymous',
          'MustBeAnonymousAnnotation',
        ),
        isTrue,
      );
    });

    test('matches an exact long-name annotation', () {
      final fn = _parseFirstFunction(
        '@MustBeAnonymousAnnotation()\nvoid foo() {}',
      );
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymous',
          'MustBeAnonymousAnnotation',
        ),
        isTrue,
      );
    });

    test(
      'does NOT match a sibling annotation that contains the name as substring',
      () {
        // Regression: previously this returned true because
        // "mustBeAnonymousOrError" contains "mustBeAnonymous" as a substring,
        // causing the warning-severity rule to fire alongside the
        // error-severity rule on the same site.
        final fn = _parseFirstFunction(
          '@mustBeAnonymousOrError\nvoid foo() {}',
        );
        expect(
          isDirectlyAnnotatedByText(
            fn,
            'mustBeAnonymous',
            'MustBeAnonymousAnnotation',
          ),
          isFalse,
        );
      },
    );

    test(
      'does NOT match a sibling long-name annotation as substring',
      () {
        final fn = _parseFirstFunction(
          '@MustBeAnonymousOrErrorAnnotation()\nvoid foo() {}',
        );
        expect(
          isDirectlyAnnotatedByText(
            fn,
            'mustBeAnonymous',
            'MustBeAnonymousAnnotation',
          ),
          isFalse,
        );
      },
    );

    test('matches prefixed annotation by simple name', () {
      // `@a.mustBeAnonymous` (prefixed import) should still match.
      final fn = _parseFirstFunction(
        'import "x" as a;\n@a.mustBeAnonymous\nvoid foo() {}',
      );
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymous',
          'MustBeAnonymousAnnotation',
        ),
        isTrue,
      );
    });

    test('returns false when no metadata is present', () {
      final fn = _parseFirstFunction('void foo() {}');
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymous',
          'MustBeAnonymousAnnotation',
        ),
        isFalse,
      );
    });

    test('does not confuse unrelated annotations', () {
      final fn = _parseFirstFunction('@override\nvoid foo() {}');
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymous',
          'MustBeAnonymousAnnotation',
        ),
        isFalse,
      );
    });

    test('warning + error variants are not confused for either name', () {
      // The warning variant's name should NOT match the OrError checker.
      final fn = _parseFirstFunction('@mustBeAnonymous\nvoid foo() {}');
      expect(
        isDirectlyAnnotatedByText(
          fn,
          'mustBeAnonymousOrError',
          'MustBeAnonymousOrErrorAnnotation',
        ),
        isFalse,
      );
    });

    test('matches an annotation on a method declaration', () {
      // Regression: the rule's MethodDeclaration handler relies on
      // isDirectlyAnnotatedByText accepting any AnnotatedNode.
      final method = _parseFirstMethod(
        'class C { @noFutures void m() async {} }',
      );
      expect(
        isDirectlyAnnotatedByText(method, 'noFutures', 'NoFuturesAnnotation'),
        isTrue,
      );
    });

    test('does not match a sibling annotation on a method declaration', () {
      final method = _parseFirstMethod(
        'class C { @noFuturesOrError void m() async {} }',
      );
      expect(
        isDirectlyAnnotatedByText(method, 'noFutures', 'NoFuturesAnnotation'),
        isFalse,
      );
    });
  });
}
