import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';
import 'package:habitflow/shared/widgets/foundation/hf_progress_bar.dart';

/// [HFGoalCard] displays progress towards a quantitative goal.
/// 
/// ### Example Usage:
/// ```dart
/// HFGoalCard(
///   title: 'Save Money',
///   currentValue: 500,
///   targetValue: 1000,
///   unit: 'dollars',
/// )
/// ```
class HFGoalCard extends StatelessWidget {
  /// Creates an [HFGoalCard].
  const HFGoalCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.color,
    this.onTap,
  });

  /// The title of the goal.
  final String title;

  /// The current progress value.
  final double currentValue;

  /// The target value to reach.
  final double targetValue;

  /// The unit of measurement (e.g., 'km', 'steps', 'USD').
  final String unit;

  /// Optional color for the progress bar. Defaults to [ColorScheme.primary].
  final Color? color;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = currentValue / targetValue;
    final goalColor = color ?? theme.colorScheme.primary;

    return HFCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: HFSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: goalColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: HFSpacing.m),
          HFProgressBar(
            progress: progress,
            color: goalColor,
          ),
          const SizedBox(height: HFSpacing.s),
          Text(
            '${currentValue.toInt()} / ${targetValue.toInt()} $unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(HFOpacity.alpha60),
            ),
          ),
        ],
      ),
    );
  }
}
