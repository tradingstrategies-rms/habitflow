import 'package:flutter/material.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';

class InsightCard extends StatelessWidget {
  final HabitInsight insight;

  const InsightCard({
    super.key,
    required this.insight,
  });

  IconData _getCategoryIcon() {
    switch (insight.category) {
      case InsightCategory.timing:
        return Icons.access_time;
      case InsightCategory.trend:
        return Icons.trending_up;
      case InsightCategory.consistency:
        return Icons.event_repeat;
      case InsightCategory.recovery:
        return Icons.healing;
      case InsightCategory.warning:
        return Icons.warning_amber;
      case InsightCategory.achievement:
        return Icons.emoji_events;
      case InsightCategory.streak:
        return Icons.local_fire_department;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _getCategoryColor(ColorScheme colorScheme) {
    switch (insight.category) {
      case InsightCategory.warning:
        return colorScheme.error;
      case InsightCategory.achievement:
        return colorScheme.primary;
      case InsightCategory.trend:
        return colorScheme.secondary;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HFSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(HFSpacing.s),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(colorScheme).withAlpha(20),
                    borderRadius: BorderRadius.circular(HFSpacing.s),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    size: 20,
                    color: _getCategoryColor(colorScheme),
                  ),
                ),
                const SizedBox(width: HFSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        insight.category.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (insight.severity == InsightSeverity.high)
                  Icon(
                    Icons.priority_high,
                    size: 16,
                    color: colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: HFSpacing.m),
            Text(
              insight.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: HFSpacing.s),
            Text(
              insight.explanation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
