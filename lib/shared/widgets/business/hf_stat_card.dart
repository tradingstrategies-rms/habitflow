import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

/// [HFStatCard] displays a single statistic or metric.
/// 
/// ### Example Usage:
/// ```dart
/// HFStatCard(
///   label: 'Total Habits',
///   value: '12',
///   icon: Icons.task_alt,
/// )
/// ```
class HFStatCard extends StatelessWidget {
  /// Creates an [HFStatCard].
  const HFStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  /// The description of the statistic.
  final String label;

  /// The value of the statistic to display prominently.
  final String value;

  /// Optional icon to represent the statistic.
  final IconData? icon;

  /// Optional theme color for the card and text. Defaults to [ColorScheme.primary].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statColor = color ?? theme.colorScheme.primary;

    return HFCard(
      color: statColor.withAlpha(HFOpacity.alpha10),
      padding: const EdgeInsets.all(HFSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: statColor, size: 24),
            const SizedBox(height: HFSpacing.s),
          ],
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: statColor,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
            ),
          ),
        ],
      ),
    );
  }
}
