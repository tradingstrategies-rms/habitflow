import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/theme/hf_spacing.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_calculation_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_transactions_provider.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_balance_card.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_error_card.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_loading_card.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_summary_card.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_transaction_tile.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_level_diamond.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/goals/application/providers/goal_providers.dart';
import 'package:habitflow/features/family/presentation/providers/family_achievement_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';

class RewardsDashboardScreen extends ConsumerWidget {
  const RewardsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremiumRewards = ref.watch(premiumServiceProvider).hasEntitlement(
      EntitlementType.premiumRewards,
    );

    if (!hasPremiumRewards) {
      return const Scaffold(
        appBar: AppBar(title: Text('Rewards')),
        body: PremiumFeatureLockedView(
          title: 'Premium Rewards',
          message: 'Unlock deeper rewards, progression, and premium recognition for your consistency.',
          icon: Icons.stars_rounded,
          entitlement: EntitlementType.premiumRewards,
        ),
      );
    }

    final session = ref.watch(activeProfileSessionProvider);
    final theme = Theme.of(context);

    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final accountAsync = ref.watch(rewardAccountProvider(profileId));
    final transactionsAsync = ref.watch(rewardTransactionsProvider(profileId));
    final calcService = ref.watch(rewardCalculationServiceProvider);

    final totalCompletions = ref.watch(allHabitCompletionsProvider).maybeWhen(
      data: (list) => list.where((c) => c.profileId == profileId).length,
      orElse: () => 0,
    );
    final activeGoalsCount = ref.watch(activeGoalsProvider).length;
    final achievementsCount = ref.watch(familyAchievementsProvider).where((a) => a.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.pushNamed(RouteNames.levelProgress),
          child: Row(
            children: [
              RewardLevelDiamond(level: accountAsync.value?.level ?? 1, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rewards'),
                  Text(
                    'Level ${accountAsync.value?.level ?? 1} - Consistency Builder',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.pushNamed(RouteNames.rewardHistory),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.familySettings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(rewardAccountProvider(profileId));
          ref.invalidate(rewardTransactionsProvider(profileId));
        },
        child: ListView(
          padding: const EdgeInsets.all(HFSpacing.m),
          children: [
            accountAsync.when(
              data: (account) {
                if (account == null) return const SizedBox.shrink();
                return RewardBalanceCard(
                  account: account,
                  levelProgress: calcService.calculateLevelProgress(account.experience),
                  onHistoryPressed: () => context.pushNamed(RouteNames.rewardHistory),
                  onRedeemPressed: () => context.pushNamed(RouteNames.rewardStore),
                );
              },
              loading: () => const RewardLoadingCard(),
              error: (e, _) => RewardErrorCard(error: e.toString()),
            ),
            const SizedBox(height: HFSpacing.l),
            _buildStatsGrid(context, totalCompletions, activeGoalsCount, achievementsCount),
            const SizedBox(height: HFSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.pushNamed(RouteNames.rewardHistory),
                  child: const Text('View All'),
                ),
              ],
            ),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No recent activity'),
                    ),
                  );
                }
                return Column(
                  children: transactions.take(3).map((t) => RewardTransactionTile(transaction: t)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, int completions, int goals, int achievements) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        RewardSummaryCard(
          value: completions.toString(),
          label: 'Habits Tracked',
          icon: Icons.checklist_rtl_rounded,
        ),
        RewardSummaryCard(
          value: goals.toString(),
          label: 'Active Goals',
          icon: Icons.flag_outlined,
          iconColor: Colors.blue,
        ),
        const RewardSummaryCard(
          value: '18d',
          label: 'Current Streak',
          icon: Icons.local_fire_department_outlined,
          iconColor: Colors.orange,
        ),
        RewardSummaryCard(
          value: achievements.toString(),
          label: 'Achievements',
          icon: Icons.emoji_events_outlined,
          iconColor: Colors.amber,
        ),
      ],
    );
  }
}
