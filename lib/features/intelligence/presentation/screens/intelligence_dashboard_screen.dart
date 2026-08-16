import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/core/theme/hf_opacity.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/insight_card.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/recommendation_card.dart';
import 'package:habitflow/features/family/presentation/widgets/family_productivity_score_card.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

class IntelligenceDashboardScreen extends ConsumerWidget {
  const IntelligenceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Actually should use a more relevant one if available, but Sprint 9.4.1 defined these:
    // advancedAnalytics, premiumRewards, premiumChallenges, unlimitedFamilies, unlimitedHabits
    // I'll use advancedAnalytics or premiumChallenges for Intelligence for now, or just check isPremium.
    final isPremium = ref.watch(premiumServiceProvider).isPremium;

    if (!isPremium) {
      return const Scaffold(
        appBar: HFTopAppBar(title: 'Intelligence'),
        body: PremiumFeatureLockedView(
          title: 'Advanced Intelligence',
          message: 'Unlock AI-powered habit insights and personalized recommendations.',
          icon: Icons.auto_awesome_rounded,
          entitlement: EntitlementType.advancedAnalytics,
        ),
      );
    }

    final dashboardDataAsync = ref.watch(intelligenceDashboardProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final isChild = activeProfile?.profileType == ProfileType.child;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intelligence'),
            Text(
              'Your habits, understood',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: dashboardDataAsync.when(
        data: (data) {
          if (data == null) {
            return const Center(
              child: HFEmptyState(
                title: 'No Data Yet',
                message: 'Complete a few more habits and we\'ll start spotting patterns.',
                icon: Icons.auto_awesome_outlined,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(HFSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.priorityInsight != null) ...[
                  _buildSectionTitle(context, 'Priority Insight'),
                  const SizedBox(height: HFSpacing.s),
                  InsightCard(insight: data.priorityInsight!),
                  const SizedBox(height: HFSpacing.l),
                ],
                if (data.topRecommendation != null) ...[
                  _buildSectionTitle(context, 'Next Step'),
                  const SizedBox(height: HFSpacing.s),
                  RecommendationCard(recommendation: data.topRecommendation!),
                  const SizedBox(height: HFSpacing.l),
                ],
                if (data.positiveInsights.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Going Well'),
                  const SizedBox(height: HFSpacing.s),
                  ...data.positiveInsights.take(2).map((insight) => Padding(
                        padding: const EdgeInsets.only(bottom: HFSpacing.m),
                        child: InsightCard(insight: insight),
                      )),
                  const SizedBox(height: HFSpacing.s),
                ],
                if (data.familyScore != null) ...[
                  _buildSectionTitle(context, 'Family Productivity'),
                  const SizedBox(height: HFSpacing.s),
                  FamilyProductivityScoreCard(isChild: isChild),
                  const SizedBox(height: HFSpacing.l),
                ],
                const SizedBox(height: HFSpacing.xl),
              ],
            ),
          );
        },
        loading: () => const Center(child: HFLoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(HFOpacity.alpha80),
          ),
    );
  }
}
