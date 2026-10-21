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

import 'package:analyzer/analysis_rule/rule_context.dart' show RuleContext;
import 'package:analyzer/dart/ast/ast.dart'
    show AnnotatedNode, Annotation, PrefixedIdentifier;
import 'package:analyzer/dart/element/type.dart' show DartType;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Returns true if [node] is annotated with an annotation whose identifier
/// exactly matches [shortName] (the const instance) or [longName] (the class).
///
/// We match on the annotation's identifier rather than via [Annotation.toSource]
/// because substring matching causes annotations like `@mustBeAnonymousOrError`
/// to match the substring `mustBeAnonymous`, firing the warning-severity rule
/// in addition to the intended error-severity rule.
bool isDirectlyAnnotatedByText(
  AnnotatedNode node,
  String shortName,
  String longName,
) {
  for (final metadata in node.metadata) {
    if (_annotationNameEquals(metadata, shortName) ||
        _annotationNameEquals(metadata, longName)) {
      return true;
    }
  }
  return false;
}

String _annotationSimpleName(Annotation metadata) {
  final name = metadata.name;
  if (name is PrefixedIdentifier) {
    return name.identifier.name;
  }
  return name.name;
}

bool _annotationNameEquals(Annotation metadata, String target) {
  final identifier = metadata.name;
  if (identifier.name == target) return true;
  return _annotationSimpleName(metadata) == target;
}

bool isFutureOrFutureOr(DartType? type) {
  return type != null && (type.isDartAsyncFuture || type.isDartAsyncFutureOr);
}

/// Whether the library analysed in [context] belongs to the package named
/// `df_safer_dart`.
///
/// `df_safer_dart` is the package that *defines* the safe types and the
/// `@unsafeOrError` primitives, so its own implementation legitimately does
/// what several rules forbid. Those rules are for consumers and skip it.
bool isInDfSaferDartPackage(RuleContext context) {
  return pubspecNameOf(context) == 'df_safer_dart';
}

/// The `name:` declared in the `pubspec.yaml` of the package that contains
/// the library analysed in [context], or `null` when there is none.
///
/// Every rule that needs it asks for every library, so the parsed name is
/// cached per pubspec and re-read only when the file's modification stamp
/// changes.
String? pubspecNameOf(RuleContext context) {
  final root = context.package?.root;
  if (root == null) return null;
  final pubspec = root.getFile('pubspec.yaml');
  if (!pubspec.exists) return null;
  final stamp = pubspec.modificationStamp;
  final cached = _pubspecNames[pubspec.path];
  if (cached != null && cached.stamp == stamp) return cached.name;
  final match = _pubspecNamePattern.firstMatch(pubspec.readAsStringSync());
  final name = match?.group(1);
  _pubspecNames[pubspec.path] = (stamp: stamp, name: name);
  return name;
}

final _pubspecNames = <String, ({int stamp, String? name})>{};

final _pubspecNamePattern = RegExp(
  r"""^name:\s*['"]?([A-Za-z0-9_]+)""",
  multiLine: true,
);
