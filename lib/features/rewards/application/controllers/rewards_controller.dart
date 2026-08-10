import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reward_account.dart';
import '../../domain/entities/reward_transaction.dart';
import '../../domain/enums/reward_type.dart';
import '../../domain/enums/reward_source.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../../domain/services/reward_calculation_service.dart';
import '../../presentation/providers/reward_account_provider.dart';
import '../../presentation/providers/reward_transactions_provider.dart';
import '../../presentation/providers/reward_calculation_provider.dart';
import '../../../leaderboards/presentation/providers/leaderboard_providers.dart';
import '../../../../core/sync/services/gamification_sync_service.dart';

import '../../data/models/reward_account_model.dart';
import '../../data/models/reward_transaction_model.dart';
import '../../../../core/sync/models/sync_operation.dart';

/// [RewardsController] coordinates reward-related operations.
class RewardsController {
  final RewardsRepository _repository;
  final Ref _ref;

  RewardsController(this._repository, this._ref);

  /// Saves or updates a [RewardAccount].
  Future<void> saveAccount(RewardAccount account) async {
    await _repository.saveAccount(account);
    _ref.invalidate(rewardAccountProvider(account.profileId));
    _ref.invalidate(currentLeaderboardProvider);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: account.profileId,
      type: SyncOperationType.updateAccount,
      data: RewardAccountModel.fromEntity(account).toJson(),
      createdAt: DateTime.now(),
    ));
  }

  /// Adds a new [RewardTransaction] and refreshes related data.
  Future<void> addTransaction(RewardTransaction transaction) async {
    await _repository.addTransaction(transaction);
    
    // Update the account balance
    final account = await _repository.getAccount(transaction.profileId);
    if (account != null) {
      final updatedAccount = _applyTransactionToAccount(account, transaction);
      await _repository.saveAccount(updatedAccount);
      
      _queueSync(SyncOperation(
        id: const Uuid().v4(),
        profileId: account.profileId,
        type: SyncOperationType.updateAccount,
        data: RewardAccountModel.fromEntity(updatedAccount).toJson(),
        createdAt: DateTime.now(),
      ));
    }

    _ref.invalidate(rewardTransactionsProvider(transaction.profileId));
    _ref.invalidate(rewardAccountProvider(transaction.profileId));
    _ref.invalidate(currentLeaderboardProvider);
    
    _queueSync(SyncOperation(
      id: const Uuid().v4(),
      profileId: transaction.profileId,
      type: SyncOperationType.addTransaction,
      data: RewardTransactionModel.fromEntity(transaction).toJson(),
      createdAt: DateTime.now(),
    ));
  }

  void _queueSync(SyncOperation operation) {
    _ref.read(gamificationSyncServiceProvider).queueOperation(operation).catchError((e) {
      // Log error silently
    });
  }

  /// Orchestrates rewarding a habit completion.
  Future<void> awardHabitCompletion(String profileId, String habitId, String habitTitle) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.pointsPerHabit,
      type: RewardType.points,
      source: RewardSource.habitCompletion,
      referenceId: habitId,
      description: 'Completed habit: $habitTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(transaction);

    final xpTransaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.xpPerHabit,
      type: RewardType.xp,
      source: RewardSource.habitCompletion,
      referenceId: habitId,
      description: 'Experience for habit: $habitTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(xpTransaction);
  }

  /// Orchestrates rewarding a goal completion.
  Future<void> awardGoalCompletion(String profileId, String goalId, String goalTitle) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.pointsPerGoal,
      type: RewardType.points,
      source: RewardSource.goalReached,
      referenceId: goalId,
      description: 'Reached goal: $goalTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(transaction);

    final xpTransaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.xpPerGoal,
      type: RewardType.xp,
      source: RewardSource.goalReached,
      referenceId: goalId,
      description: 'Experience for goal: $goalTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(xpTransaction);
  }

  /// Orchestrates rewarding an achievement unlock.
  Future<void> awardAchievement(String profileId, String achievementId, String achievementName) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.pointsPerAchievement,
      type: RewardType.points,
      source: RewardSource.achievementUnlocked,
      referenceId: achievementId,
      description: 'Unlocked achievement: $achievementName',
      createdAt: DateTime.now(),
    );
    await addTransaction(transaction);

    final xpTransaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.xpPerAchievement,
      type: RewardType.xp,
      source: RewardSource.achievementUnlocked,
      referenceId: achievementId,
      description: 'Experience for achievement: $achievementName',
      createdAt: DateTime.now(),
    );
    await addTransaction(xpTransaction);
  }

  /// Orchestrates rewarding a streak milestone.
  Future<void> awardStreakMilestone(String profileId, int streak, String habitTitle) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.pointsPerStreakMilestone,
      type: RewardType.points,
      source: RewardSource.streakMilestone,
      description: '$streak day streak on $habitTitle! 🔥',
      createdAt: DateTime.now(),
    );
    await addTransaction(transaction);

    final xpTransaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: RewardCalculationService.xpPerStreakMilestone,
      type: RewardType.xp,
      source: RewardSource.streakMilestone,
      description: 'Experience for $streak day streak',
      createdAt: DateTime.now(),
    );
    await addTransaction(xpTransaction);
  }

  /// Orchestrates rewarding a challenge completion.
  Future<void> awardChallengeCompletion(String profileId, String challengeId, String challengeTitle, int points, int xp) async {
    final transaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: points,
      type: RewardType.points,
      source: RewardSource.challengeCompletion,
      referenceId: challengeId,
      description: 'Completed challenge: $challengeTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(transaction);

    final xpTransaction = RewardTransaction(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: xp,
      type: RewardType.xp,
      source: RewardSource.challengeCompletion,
      referenceId: challengeId,
      description: 'Experience for challenge: $challengeTitle',
      createdAt: DateTime.now(),
    );
    await addTransaction(xpTransaction);
  }

  /// Helper to apply transaction to account state.
  RewardAccount _applyTransactionToAccount(RewardAccount account, RewardTransaction transaction) {
    int newPoints = account.points;
    int newXp = account.experience;
    int newLifetime = account.lifetimeEarnings;

    if (transaction.type == RewardType.points) {
      newPoints += transaction.amount;
      if (transaction.amount > 0) {
        newLifetime += transaction.amount;
      }
    } else if (transaction.type == RewardType.xp) {
      newXp += transaction.amount;
    }

    final calcService = _ref.read(rewardCalculationServiceProvider);
    final newLevel = calcService.calculateLevelFromExperience(newXp);

    return account.copyWith(
      points: newPoints,
      experience: newXp,
      level: newLevel,
      lifetimeEarnings: newLifetime,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Manually refreshes a specific profile's reward data.
  void refresh(String profileId) {
    _ref.invalidate(rewardAccountProvider(profileId));
    _ref.invalidate(rewardTransactionsProvider(profileId));
  }
}
