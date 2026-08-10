import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../habits/domain/entities/habit_completion.dart';
import '../providers/goal_providers.dart';

/// [GoalCompletionWatcher] coordinates the detection and recording of
/// goal completions by observing habit activity.
class GoalCompletionWatcher {
  final Ref _ref;

  GoalCompletionWatcher(this._ref);

  /// Analyzes all active goals against the latest habit completions.
  Future<void> checkAllGoals(List<HabitCompletion> completions) async {
    final activeGoals = _ref.read(activeGoalsProvider);
    final aggregator = _ref.read(progressAggregatorProvider);
    final service = _ref.read(goalCompletionServiceProvider);

    // Identify the profile that might have triggered this check
    String? profileId;
    if (completions.isNotEmpty) {
      // Assuming the last completion in the list is the one that triggered the change
      profileId = completions.last.profileId;
    }

    for (final goal in activeGoals) {
      final progress = aggregator.aggregate(goal, completions);
      if (progress.isCompleted) {
        await service.checkAndRecordCompletion(goal, progress, profileId: profileId);
      }
    }
  }
}
