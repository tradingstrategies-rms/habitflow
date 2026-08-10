import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/consistency_score_card.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/behavior_patterns_section.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/insight_card.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/recommendation_card.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/section_header.dart';

class IntelligenceDashboardScreen extends ConsumerWidget {
  const IntelligenceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intelligenceDataAsync = ref.watch(intelligenceSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Intelligence'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: HFSpacing.m),
            child: Icon(Icons.notifications_none, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
      body: intelligenceDataAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(HFSpacing.l),
              child: Text('When enough habit data is available, your intelligence insights will appear.', textAlign: TextAlign.center),
            ));
          }
          return RefreshIndicator(
            onRefresh: () async {
              // ref.refresh(intelligenceSummaryProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: HFSpacing.m, vertical: HFSpacing.s),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ConsistencyScoreCard(score: data.consistencyScore),
                      const SizedBox(height: HFSpacing.l),
                      BehaviorPatternsSection(
                        patterns: data.patterns,
                        title: 'Behavior Patterns',
                      ),
                      const SizedBox(height: HFSpacing.l),
                      SectionHeader(
                        title: 'Tailored Insights',
                        actionLabel: 'View All',
                        onActionPressed: () {},
                      ),
                      ...data.insights.map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: HFSpacing.m),
                        child: InsightCard(insight: insight),
                      )),
                      const SizedBox(height: HFSpacing.s),
                      RecommendationCard(
                        recommendation: data.topRecommendation,
                        onActionPressed: () {},
                      ),
                      const SizedBox(height: HFSpacing.xl),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
