import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/insight_card.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/recommendation_card.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';

class HabitIntelligenceSection extends ConsumerWidget {
  final String habitId;
  final Duration period;

  const HabitIntelligenceSection({
    super.key,
    required this.habitId,
    required this.period,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intelligenceAsync = ref.watch(habitIntelligenceProvider((habitId, period)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intelligence',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: HFSpacing.m),
        intelligenceAsync.when(
          data: (result) {
            if (result.insights.isEmpty && result.recommendations.isEmpty) {
              return const Text('Insufficient data to generate insights for this period.');
            }

            return Column(
              children: [
                if (result.recommendations.isNotEmpty) ...[
                  RecommendationCard(recommendation: result.recommendations.first),
                  const SizedBox(height: HFSpacing.l),
                ],
                if (result.insights.isNotEmpty)
                  ...result.insights.take(2).map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: HFSpacing.m),
                    child: InsightCard(insight: insight),
                  )),
              ],
            );
          },
          loading: () => const Center(child: HFLoadingIndicator()),
          error: (err, stack) => Text('Error loading intelligence: $err'),
        ),
      ],
    );
  }
}
