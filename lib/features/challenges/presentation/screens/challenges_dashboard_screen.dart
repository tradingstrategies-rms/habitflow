import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import '../../domain/entities/challenge_progress.dart';
import '../providers/challenge_providers.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';

class ChallengesDashboardScreen extends ConsumerWidget {
  const ChallengesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremiumChallenges = ref.watch(premiumServiceProvider).hasEntitlement(
      EntitlementType.premiumChallenges,
    );

    if (!hasPremiumChallenges) {
      return const Scaffold(
        appBar: AppBar(title: Text('Challenges')),
        body: PremiumFeatureLockedView(
          title: 'Premium Challenges',
          message: 'Take on deeper challenges designed to keep your momentum strong and make progress more rewarding.',
          icon: Icons.emoji_events_rounded,
          entitlement: EntitlementType.premiumChallenges,
        ),
      );
    }

    final session = ref.watch(activeProfileSessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final activeChallengesAsync = ref.watch(activeChallengesProvider(profileId));
    final profileProgressAsync = ref.watch(profileProgressProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.pushNamed(RouteNames.completedChallenges),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeChallengesProvider(profileId));
          ref.invalidate(profileProgressProvider(profileId));
        },
        child: activeChallengesAsync.when(
          data: (challenges) {
            if (challenges.isEmpty) {
              return const ChallengeEmptyState();
            }

            final progressRecords = profileProgressAsync.value ?? [];

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                final progress = progressRecords.firstWhere(
                  (p) => p.challengeId == challenge.id,
                  orElse: () => ChallengeProgress(
                    challengeId: challenge.id,
                    profileId: profileId,
                    lastUpdatedAt: DateTime.now(),
                    periodStartDate: DateTime.now(),
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ChallengeCard(
                    challenge: challenge,
                    progress: progress,
                    onTap: () => context.pushNamed(
                      RouteNames.challengeDetail,
                      pathParameters: {'challengeId': challenge.id},
                      extra: {'challenge': challenge, 'progress': progress},
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
