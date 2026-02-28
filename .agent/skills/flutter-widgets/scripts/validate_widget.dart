// Dart validation script for Flutter widgets generated from Stitch designs.
//
// Checks:
//   1. Widget class extends StatelessWidget or StatefulWidget
//   2. No hardcoded hex colors (Color(0x...) patterns)
//   3. Constructor parameters are declared as final
//   4. Template placeholder "StitchWidget" has been replaced
//
// Usage:
//   dart run scripts/validate_widget.dart <file_path>

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run scripts/validate_widget.dart <file_path>');
    exit(1);
  }

  final filePath = args[0];
  final file = File(filePath);

  if (!file.existsSync()) {
    stderr.writeln('❌ File not found: $filePath');
    exit(1);
  }

  final content = file.readAsStringSync();
  final lines = content.split('\n');
  final filename = file.uri.pathSegments.last;

  print('🔍 Validating: $filename');
  print('---');

  var passed = true;

  // ------------------------------------------------------------------
  // 1. Check for StatelessWidget or StatefulWidget extension
  // ------------------------------------------------------------------
  final widgetPattern = RegExp(
    r'class\s+\w+\s+extends\s+(Stateless|Stateful)Widget',
  );
  if (widgetPattern.hasMatch(content)) {
    print('✅ Widget class found (extends StatelessWidget or StatefulWidget).');
  } else {
    stderr.writeln(
      '❌ MISSING: No class extending StatelessWidget or StatefulWidget.',
    );
    passed = false;
  }

  // ------------------------------------------------------------------
  // 2. Check for hardcoded hex colors
  // ------------------------------------------------------------------
  final hexColorPattern = RegExp(r'Color\(0x[0-9A-Fa-f]+\)');
  final hexMatches = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    // Skip lines that are comments
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//') || trimmed.startsWith('*')) continue;

    for (final match in hexColorPattern.allMatches(line)) {
      hexMatches.add('  Line ${i + 1}: ${match.group(0)}');
    }
  }

  if (hexMatches.isEmpty) {
    print('✅ No hardcoded hex colors found.');
  } else {
    stderr.writeln(
      '❌ STYLE: Found ${hexMatches.length} hardcoded Color(0x...) values. '
      'Use Theme.of(context) instead.',
    );
    for (final m in hexMatches) {
      stderr.writeln(m);
    }
    passed = false;
  }

  // ------------------------------------------------------------------
  // 3. Check that constructor parameters are final
  // ------------------------------------------------------------------
  // Look for non-final instance fields (simple heuristic: lines with
  // a type + identifier that are NOT final, static, or late final)
  final nonFinalFieldPattern = RegExp(
    r'^\s+(?!final\b|static\b|late\s+final\b|const\b|@)\w+[\w<>,\s\?]*\s+\w+\s*;',
  );
  final nonFinalFields = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (nonFinalFieldPattern.hasMatch(line)) {
      // Exclude common false positives (method bodies, local variables, etc.)
      final trimmed = line.trim();
      if (!trimmed.startsWith('return') &&
          !trimmed.startsWith('var ') &&
          !trimmed.startsWith('//')) {
        nonFinalFields.add('  Line ${i + 1}: ${trimmed}');
      }
    }
  }

  if (nonFinalFields.isEmpty) {
    print('✅ All fields appear to be final/const.');
  } else {
    stderr.writeln(
      '⚠️  WARNING: Found ${nonFinalFields.length} potentially non-final '
      'field(s). Widget fields should be final:',
    );
    for (final f in nonFinalFields) {
      stderr.writeln(f);
    }
    // This is a warning, not a hard failure
  }

  // ------------------------------------------------------------------
  // 4. Check for unresolved template placeholder
  // ------------------------------------------------------------------
  if (content.contains('StitchWidget')) {
    stderr.writeln(
      '❌ TEMPLATE: Found unreplaced "StitchWidget" placeholder. '
      'Replace with the actual widget name.',
    );
    passed = false;
  } else {
    print('✅ No template placeholders found.');
  }

  // ------------------------------------------------------------------
  // Result
  // ------------------------------------------------------------------
  print('---');
  if (passed) {
    print('✨ WIDGET VALID.');
    exit(0);
  } else {
    stderr.writeln('🚫 VALIDATION FAILED.');
    exit(1);
  }
}
