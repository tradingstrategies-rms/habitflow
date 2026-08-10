/// [GoalHabitContribution] represents the quantitative contribution 
/// of a specific habit to a parent goal.
class GoalHabitContribution {
  /// Unique identifier of the habit.
  final String habitId;

  /// Display name of the habit.
  final String habitName;

  /// Number of times this habit was completed within the goal timeframe.
  final int completionCount;

  /// Percentage contribution to the total goal progress (0.0 to 1.0).
  final double percentageContribution;

  const GoalHabitContribution({
    required this.habitId,
    required this.habitName,
    required this.completionCount,
    required this.percentageContribution,
  });
}
