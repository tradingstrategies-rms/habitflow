import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/domain/enums/entitlement_type.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/shared/widgets/widgets.dart';
import '../../domain/entities/challenge_progress.dart';
import '../providers/challenge_providers.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';

class CompletedChallengesScreen extends ConsumerWidget {
  const CompletedChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumServiceProvider).hasEntitlement(EntitlementType.premiumChallenges);
    
    if (!isPremium) {
      return const Scaffold(
        appBar: HFTopAppBar(title: 'Hall of Fame'),
        body: PremiumFeatureLockedView(
          title: 'Challenge History',
          message: 'Upgrade to see your past achievements and completed challenges!',
          icon: Icons.workspace_premium_outlined,
          entitlement: EntitlementType.premiumChallenges,
        ),
      );
    }

    final session = ref.watch(activeProfileSessionProvider);

    if (session == null) {
      return const Scaffold(body: Center(child: Text('Please select a profile')));
    }

    final profileId = session.profileId;
    final completedChallengesAsync = ref.watch(completedChallengesProvider(profileId));
    final profileProgressAsync = ref.watch(profileProgressProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hall of Fame'),
      ),
      body: completedChallengesAsync.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return const ChallengeEmptyState(
              title: 'No Completed Challenges',
              message: 'Finish your first challenge to see it here!',
              icon: Icons.workspace_premium_outlined,
            );
          }

          final progressRecords = profileProgressAsync.value ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              final progress = progressRecords.cast<ChallengeProgress?>().firstWhere(
                (p) => p?.challengeId == challenge.id,
                orElse: () => null,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ChallengeCard(
                  challenge: challenge,
                  progress: progress,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
