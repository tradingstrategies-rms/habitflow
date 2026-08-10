import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import '../../domain/entities/challenge_progress.dart';
import '../providers/challenge_providers.dart';
import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';

class CompletedChallengesScreen extends ConsumerWidget {
  const CompletedChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
