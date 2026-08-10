import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../../domain/services/challenge_lifecycle_service.dart';
import '../../presentation/providers/challenge_providers.dart';
import '../../data/models/challenge_progress_model.dart';
import '../../../rewards/application/controllers/rewards_controller.dart';
import '../../../../core/sync/services/gamification_sync_service.dart';
import '../../../../core/sync/models/sync_operation.dart';

class ChallengesController {
  final ChallengesRepository _repository;
  final RewardsController _rewardsController;
  final ChallengeLifecycleService _lifecycleService;
  final Ref _ref;

  ChallengesController(this._repository, this._rewardsController, this._lifecycleService, this._ref);

  Future<void> updateProgress(String profileId, String challengeId, double newValue) async {
    final challenge = await _repository.getChallengeById(challengeId);
    if (challenge == null) return;

    final now = DateTime.now();
    final periodStart = _lifecycleService.calculateCurrentPeriodStart(challenge, now);

    final existingProgress = await _repository.getProgress(challengeId, profileId, periodStartDate: periodStart);
    
    if (existingProgress != null && existingProgress.isCompleted) return;

    final isCompleted = newValue >= challenge.targetValue;
    
    final progress = ChallengeProgress(
      challengeId: challengeId,
      profileId: profileId,
      currentValue: newValue,
      isCompleted: isCompleted,
      completedAt: isCompleted ? now : null,
      lastUpdatedAt: now,
      periodStartDate: periodStart,
    );

    await _repository.saveProgress(progress);

    if (isCompleted) {
      await _rewardsController.awardChallengeCompletion(
        profileId,
        challenge.id,
        challenge.title,
        challenge.pointReward,
        challenge.xpReward,
      );
    }

    _refreshProviders(profileId, challengeId);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: profileId,
      type: SyncOperationType.updateChallengeProgress,
      data: ChallengeProgressModel.fromEntity(progress).toJson(),
      createdAt: now,
    ));
  }

  void _queueSync(SyncOperation operation) {
    _ref.read(gamificationSyncServiceProvider).queueOperation(operation).catchError((e) {
      // Log silently
    });
  }

  // To be used by integrations (Habits, Goals etc)
  Future<void> incrementProgress(String profileId, String challengeId, double increment) async {
    final challenge = await _repository.getChallengeById(challengeId);
    if (challenge == null) return;

    final now = DateTime.now();
    final periodStart = _lifecycleService.calculateCurrentPeriodStart(challenge, now);
    
    final existing = await _repository.getProgress(challengeId, profileId, periodStartDate: periodStart);
    final current = existing?.currentValue ?? 0;
    await updateProgress(profileId, challengeId, current + increment);
  }

  /// Increments progress for all active challenges related to a specific ID (e.g. habitId).
  Future<void> incrementProgressByRelatedId(String profileId, String relatedId, double increment) async {
    final activeChallenges = await _repository.getActiveChallenges();
    for (final challenge in activeChallenges) {
      // Check eligibility
      if (challenge.eligibleProfileIds.isNotEmpty && !challenge.eligibleProfileIds.contains(profileId)) {
        continue;
      }

      if (challenge.relatedId == relatedId || challenge.relatedId == null) {
        // If relatedId is null, it might be a general challenge like "Complete any habit"
        // For now, if relatedId matches OR if it's a general habit challenge (type check needed)
        // We'll refine this logic as we go.
        await incrementProgress(profileId, challenge.id, increment);
      }
    }
  }

  void _refreshProviders(String profileId, String challengeId) {
    _ref.invalidate(profileProgressProvider(profileId));
    _ref.invalidate(challengeProgressProvider((challengeId, profileId)));
    _ref.invalidate(completedChallengesProvider(profileId));
  }
}
