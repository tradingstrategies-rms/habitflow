import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

/// [HFBadge] is a small indicator for level, count, or status.
/// 
/// ### Example Usage:
/// ```dart
/// HFBadge(
///   label: '5',
///   color: Colors.orange,
/// )
/// ```
class HFBadge extends StatelessWidget {
  /// Creates an [HFBadge].
  const HFBadge({
    super.key,
    required this.label,
    this.color,
    this.semanticsLabel,
  });

  /// The text label to display inside the badge.
  final String label;

  /// The background color of the badge. Defaults to [ColorScheme.primary].
  final Color? color;
  
  /// Optional accessibility label for the badge.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;

    return Semantics(
      label: semanticsLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HFSpacing.s,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
