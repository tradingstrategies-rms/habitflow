import '../../../features/goals/domain/enums/goal_type.dart';

/// Represents the raw metrics aggregated from completion data.
class ProgressMetrics {
  /// The type of goal these metrics are for.
  final GoalType type;

  /// The raw count of completions.
  final int completionCount;

  /// The current streak length.
  final int currentStreak;

  /// The maximum streak length achieved.
  final int maxStreak;

  /// The total numeric value accumulated (if applicable).
  final double totalValue;

  /// The average completion rate or percentage.
  final double averageValue;

  /// The date of the last recorded completion.
  final DateTime? lastCompletionDate;

  /// Creates an immutable [ProgressMetrics].
  const ProgressMetrics({
    required this.type,
    this.completionCount = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.totalValue = 0.0,
    this.averageValue = 0.0,
    this.lastCompletionDate,
  });
}
