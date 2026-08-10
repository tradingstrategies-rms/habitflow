import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_radius.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_pattern.dart';

class BehaviorPatternChip extends StatelessWidget {
  final HabitPattern pattern;

  const BehaviorPatternChip({
    super.key,
    required this.pattern,
  });

  IconData _getIcon() {
    switch (pattern.type) {
      case PatternType.morningStrength:
        return Icons.wb_sunny_outlined;
      case PatternType.eveningStrength:
        return Icons.nightlight_outlined;
      case PatternType.weekdayStrength:
        return Icons.work_outline;
      case PatternType.weekendWeakness:
        return Icons.weekend_outlined;
      case PatternType.improvingTrend:
        return Icons.trending_up;
      case PatternType.decliningTrend:
        return Icons.trending_down;
      case PatternType.highConsistency:
        return Icons.verified_outlined;
      case PatternType.lowConsistency:
        return Icons.warning_amber_outlined;
      case PatternType.longInactiveGap:
        return Icons.pause_circle_outline;
      case PatternType.fastRecovery:
        return Icons.bolt_outlined;
      case PatternType.slowRecovery:
        return Icons.hourglass_empty;
      case PatternType.bestDayOfWeek:
        return Icons.star_outline;
      case PatternType.weakestDayOfWeek:
        return Icons.info_outline;
      default:
        return Icons.lightbulb_outline;
    }
  }

  String _getLabel() {
    // This should eventually be localized using pattern.titleKey
    switch (pattern.type) {
      case PatternType.morningStrength:
        return 'Morning Strength';
      case PatternType.eveningStrength:
        return 'Evening Strength';
      case PatternType.weekdayStrength:
        return 'Weekday Strength';
      case PatternType.weekendWeakness:
        return 'Weekend Weakness';
      case PatternType.improvingTrend:
        return 'Improving Trend';
      case PatternType.decliningTrend:
        return 'Declining Trend';
      case PatternType.highConsistency:
        return 'High Consistency';
      case PatternType.lowConsistency:
        return 'Low Consistency';
      case PatternType.longInactiveGap:
        return 'Long Gap';
      case PatternType.fastRecovery:
        return 'Fast Recovery';
      case PatternType.slowRecovery:
        return 'Slow Recovery';
      case PatternType.bestDayOfWeek:
        return 'Best Day';
      case PatternType.weakestDayOfWeek:
        return 'Weakest Day';
      default:
        return 'Insight';
    }
  }

  Color _getChipColor(ColorScheme colorScheme) {
    return switch (pattern.severity) {
      PatternSeverity.high => colorScheme.error.withAlpha(26),
      PatternSeverity.medium => colorScheme.secondary.withAlpha(26),
      PatternSeverity.low => colorScheme.primary.withAlpha(26),
    };
  }

  Color _getContentColor(ColorScheme colorScheme) {
    return switch (pattern.severity) {
      PatternSeverity.high => colorScheme.error,
      PatternSeverity.medium => colorScheme.secondary,
      PatternSeverity.low => colorScheme.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: HFSpacing.sm,
        vertical: HFSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getChipColor(colorScheme),
        borderRadius: BorderRadius.circular(HFRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 16,
            color: _getContentColor(colorScheme),
          ),
          const SizedBox(width: HFSpacing.xs),
          Text(
            _getLabel(),
            style: textTheme.labelSmall?.copyWith(
              color: _getContentColor(colorScheme),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
