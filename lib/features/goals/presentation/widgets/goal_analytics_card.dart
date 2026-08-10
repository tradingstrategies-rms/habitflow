import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/analytics/providers/goal_analytics_providers.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';
import 'package:habitflow/shared/widgets/foundation/hf_chip.dart';

class GoalAnalyticsCard extends ConsumerWidget {
  final String goalId;

  const GoalAnalyticsCard({
    super.key,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(goalAnalyticsProvider(goalId));
    final theme = Theme.of(context);

    return analyticsAsync.when(
      data: (analytics) {
        if (analytics.totalDays == 0) return const SizedBox();

        return HFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Progress',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (analytics.isConsistent)
                    HFChip(
                      label: 'EXCELLENT',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: HFSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricItem(
                    label: 'Rate',
                    value: '${(analytics.completionRate * 100).toInt()}%',
                    icon: Icons.auto_graph_rounded,
                  ),
                  _MetricItem(
                    label: 'Current',
                    value: '${analytics.currentStreak}d',
                    icon: Icons.local_fire_department_rounded,
                    iconColor: Colors.orange,
                  ),
                  _MetricItem(
                    label: 'Best',
                    value: '${analytics.bestStreak}d',
                    icon: Icons.emoji_events_rounded,
                    iconColor: Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: HFSpacing.m),
              if (analytics.isConsistent)
                Row(
                  children: [
                    Icon(
                      Icons.eco_rounded,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: HFSpacing.s),
                    Text(
                      'Excellent consistency!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () => const HFCard(child: Center(child: CircularProgressIndicator())),
      error: (err, _) => const SizedBox(),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 24),
        const SizedBox(height: HFSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}
