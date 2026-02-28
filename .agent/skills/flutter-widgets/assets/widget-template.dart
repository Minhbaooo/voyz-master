import 'package:flutter/material.dart';

/// Template for Stitch-generated Flutter widgets.
///
/// Usage: Find and replace all instances of `StitchWidget` with the actual
/// widget name before using this template.

class StitchWidget extends StatelessWidget {
  const StitchWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
