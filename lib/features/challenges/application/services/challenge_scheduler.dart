import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../../domain/services/challenge_lifecycle_service.dart';
import '../../presentation/providers/challenge_providers.dart';

class ChallengeScheduler {
  final ChallengesRepository _repository;
  final ChallengeLifecycleService _lifecycleService;
  final Ref _ref;

  ChallengeScheduler(this._repository, this._lifecycleService, this._ref);

  /// Evaluates all challenges for a specific profile and resets progress if needed.
  Future<void> evaluateChallenges(String profileId) async {
    final now = DateTime.now();
    final challenges = await _repository.getActiveChallenges();
    final profileProgress = await _repository.getAllProgressForProfile(profileId);

    for (final challenge in challenges) {
      if (!_lifecycleService.isChallengeActive(challenge, now)) continue;

      final currentPeriodStart = _lifecycleService.calculateCurrentPeriodStart(challenge, now);
      
      final existingProgress = profileProgress.where((p) => p.challengeId == challenge.id).toList();
      
      // Check if we have progress for the CURRENT period
      final hasCurrentPeriodProgress = existingProgress.any((p) => p.periodStartDate == currentPeriodStart);

      if (!hasCurrentPeriodProgress && challenge.isRecurring) {
        // We need to initialize progress for the new period
        final newProgress = ChallengeProgress(
          challengeId: challenge.id,
          profileId: profileId,
          periodStartDate: currentPeriodStart,
          lastUpdatedAt: now,
        );
        await _repository.saveProgress(newProgress);
      }
    }

    _ref.invalidate(profileProgressProvider(profileId));
  }
}
