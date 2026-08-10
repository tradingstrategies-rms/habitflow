import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/goals/analytics/providers/goal_analytics_providers.dart';
import 'package:habitflow/shared/widgets/foundation/hf_card.dart';

class GoalInsightCard extends ConsumerWidget {
  final String goalId;

  const GoalInsightCard({
    super.key,
    required this.goalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(goalInsightProvider(goalId));
    final theme = Theme.of(context);

    return insightAsync.when(
      data: (insight) {
        if (insight.isEmpty) return const SizedBox();

        return HFCard(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          elevation: 0,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(HFSpacing.s),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lightbulb_rounded, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: HFSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HF Insight',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: HFSpacing.xs),
                    Text(
                      insight,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
