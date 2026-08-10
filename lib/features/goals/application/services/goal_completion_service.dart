import '../../../../core/progress/models/progress_summary.dart';
import '../../../../core/achievements/events/goal_completed_event.dart';
import '../../../../core/achievements/services/achievement_event_bus.dart';
import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_status.dart';
import '../controllers/goal_controller.dart';
import '../../../rewards/application/controllers/rewards_controller.dart';
import '../../../challenges/application/controllers/challenges_controller.dart';

/// [GoalCompletionService] is responsible for detecting goal completion
/// and updating the goal status in the repository.
class GoalCompletionService {
  final GoalController _goalController;
  final AchievementEventBus _eventBus;
  final RewardsController? _rewardsController;
  final ChallengesController? _challengesController;

  GoalCompletionService(this._goalController, this._eventBus, [this._rewardsController, this._challengesController]);

  /// Checks if a [goal] has been completed based on its [progress].
  /// If it is completed and currently active, updates its status to [GoalStatus.completed].
  Future<void> checkAndRecordCompletion(Goal goal, ProgressSummary progress, {String? profileId}) async {
    if (goal.status != GoalStatus.active) return;

    final bool isActuallyCompleted = progress.isCompleted || progress.percentage >= 100.0;

    if (isActuallyCompleted) {
      final completedGoal = Goal(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        habitIds: goal.habitIds,
        type: goal.type,
        scope: goal.scope,
        status: GoalStatus.completed,
        targetValue: goal.targetValue,
        createdAt: goal.createdAt,
        startDate: goal.startDate,
        endDate: goal.endDate,
        colorValue: goal.colorValue,
        iconName: goal.iconName,
      );

      await _goalController.updateGoal(completedGoal);

      // Award Rewards
      if (_rewardsController != null && profileId != null) {
        await _rewardsController.awardGoalCompletion(profileId, goal.id, goal.title);
      }

      // Update Challenge Progress
      if (_challengesController != null && profileId != null) {
        await _challengesController.incrementProgressByRelatedId(profileId, goal.id, 1);
      }

      // Emit celebration event
      await _eventBus.publishGoalCompleted(
        GoalCompletedEvent(
          goalId: goal.id,
          goalTitle: goal.title,
          completedAt: DateTime.now(),
          targetValue: goal.targetValue,
          achievementMessage: 'Amazing work! You\'ve reached your milestone.',
        ),
      );
    }
  }
}
