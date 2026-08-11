import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import '../../../core/theme/hf_spacing.dart';
import '../../goals/presentation/widgets/dashboard_goal_summary.dart';
import '../../home/presentation/widgets/intelligence_preview_card.dart';
import '../../rewards/presentation/widgets/reward_preview_card.dart';
import '../../challenges/presentation/widgets/challenge_preview_card.dart';
import '../../leaderboards/presentation/widgets/leaderboard_preview_card.dart';
import '../../analytics/presentation/widgets/analytics_preview_card.dart';
import '../../../../core/sync/widgets/sync_status_indicator.dart';
import 'package:habitflow/features/authentication/application/auth_controller.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFamily = ref.watch(familyProvider.select((s) => s.circle != null));
    final circleName = ref.watch(familyProvider.select((s) => s.circle?.name ?? 'Family Circle'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitFlow'),
        actions: [
          const SyncStatusIndicator(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.pushNamed(RouteNames.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HFSpacing.m),
        child: Column(
          children: [
            const DashboardGoalSummary(),
            const SizedBox(height: HFSpacing.l),
            IntelligencePreviewCard(
              onTap: () => context.push('/intelligence'),
            ),
            const SizedBox(height: HFSpacing.l),
            const RewardPreviewCard(),
            const SizedBox(height: HFSpacing.l),
            const ChallengePreviewCard(),
            const SizedBox(height: HFSpacing.l),
            const LeaderboardPreviewCard(),
            const SizedBox(height: HFSpacing.l),
            const AnalyticsPreviewCard(),
            const SizedBox(height: HFSpacing.l),
            Card(
              child: ListTile(
                title: Text(circleName),
                subtitle: Text(hasFamily ? 'View family dashboard' : 'Bring your family together.'),
                leading: const Icon(Icons.family_restroom),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(
                  hasFamily ? RouteNames.family : RouteNames.familyCreate,
                ),
              ),
            ),
            // Other dashboard widgets will go here
          ],
        ),
      ),
    );
  }
}
