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
