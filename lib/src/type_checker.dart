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

import 'package:analyzer/dart/element/element.dart'
    show Element, InterfaceElement;
import 'package:analyzer/dart/element/type.dart' show DartType;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Matches a type by its simple [name] and, when given, the [packageName] of
/// the library that declares it.
///
/// This is a dependency-free port of `TypeChecker.fromName` from
/// `custom_lint_core` (itself from `source_gen`), which the rules relied on
/// before the move to the analyzer plugin system. The matching semantics are
/// kept identical so that every rule fires on exactly the same code.
final class NamedTypeChecker {
  /// The simple name of the type, e.g. `Outcome`.
  final String name;

  /// The package whose library must declare the type, e.g. `df_safer_dart`.
  /// When `null`, any library matches.
  final String? packageName;

  const NamedTypeChecker(this.name, {this.packageName});

  /// Whether [element] is the type this checker describes.
  bool isExactly(Element element) {
    if (element.name != name) return false;
    final package = packageName;
    if (package == null) return true;
    final targetUri = element.library?.uri;
    if (targetUri == null) return false;
    if (package == targetUri.toString()) return true;
    final targetPackageName = targetUri.pathSegments.firstOrNull;
    return targetPackageName != null && targetPackageName == package;
  }

  /// Whether the element of [staticType] is the type this checker describes.
  bool isExactlyType(DartType staticType) {
    final element = staticType.element;
    return element != null && isExactly(element);
  }

  /// Whether [element] is the described type or has it as a supertype.
  bool isAssignableFrom(Element element) {
    return isExactly(element) ||
        (element is InterfaceElement &&
            element.allSupertypes.any(isExactlyType));
  }

  /// Whether [staticType] is the described type or has it as a supertype.
  bool isAssignableFromType(DartType staticType) {
    final element = staticType.element;
    return element != null && isAssignableFrom(element);
  }

  /// Whether [element] carries an annotation whose constant value is
  /// assignable to the described type.
  ///
  /// An annotation whose constant value cannot be computed (for example
  /// because it refers to an undefined name) is skipped. The analyzer already
  /// reports that problem itself; throwing here would only crash the plugin
  /// for the whole library.
  bool hasAnnotationOf(Element element) {
    for (final annotation in element.metadata.annotations) {
      final type = annotation.computeConstantValue()?.type;
      if (type != null && isAssignableFromType(type)) return true;
    }
    return false;
  }
}
