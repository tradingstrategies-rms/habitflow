import 'goal_habit_contribution.dart';

/// [GoalAnalyticsSummary] provides a comprehensive overview of 
/// achievement patterns and consistency for a specific goal.
class GoalAnalyticsSummary {
  final String goalId;

  /// Total number of days since the goal started (or up to its end date).
  final int totalDays;

  /// Number of days on which at least one linked habit was completed.
  final int completedDays;

  /// Efficiency ratio (0.0 to 1.0).
  final double completionRate;

  /// Length of the current consecutive completion streak.
  final int currentStreak;

  /// Length of the longest consecutive completion streak recorded.
  final int bestStreak;

  /// Mean number of days between completions.
  final double averageCompletionGap;

  /// The habit that has contributed most to this goal's progress.
  final GoalHabitContribution? mostContributingHabit;

  /// Qualitative consistency flag based on the completion rate.
  final bool isConsistent;

  const GoalAnalyticsSummary({
    required this.goalId,
    required this.totalDays,
    required this.completedDays,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.averageCompletionGap,
    this.mostContributingHabit,
    required this.isConsistent,
  });

  /// Factory for empty analytics when no data is available.
  factory GoalAnalyticsSummary.empty(String goalId) {
    return GoalAnalyticsSummary(
      goalId: goalId,
      totalDays: 0,
      completedDays: 0,
      completionRate: 0.0,
      currentStreak: 0,
      bestStreak: 0,
      averageCompletionGap: 0.0,
      isConsistent: false,
    );
  }
}
