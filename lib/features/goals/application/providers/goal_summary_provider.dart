import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/progress/models/progress_summary.dart';
import '../../domain/entities/goal.dart';
import '../../domain/enums/goal_status.dart';
import 'goal_providers.dart';

/// [GoalSummary] represents the consolidated data for a goal on the dashboard.
class GoalSummary {
  final Goal goal;
  final ProgressSummary progress;

  const GoalSummary({
    required this.goal,
    required this.progress,
  });

  double get percentage => progress.percentage;
  GoalStatus get status => goal.status;
  double get remaining => progress.remaining;
  bool get isCompleted => progress.isCompleted;
}

/// Provider that exposes a list of [GoalSummary] for all active goals.
final activeGoalSummariesProvider = FutureProvider<List<GoalSummary>>((ref) async {
  final activeGoals = ref.watch(activeGoalsProvider);
  
  final summaries = <GoalSummary>[];
  
  for (final goal in activeGoals) {
    // We fetch progress for each active goal.
    // Note: goalProgressProvider is a FutureProvider.family
    final progress = await ref.watch(goalProgressProvider(goal).future);
    summaries.add(GoalSummary(goal: goal, progress: progress));
  }
  
  return summaries;
});
