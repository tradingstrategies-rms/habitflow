/// Represents the calculated progress summary for a goal or habit.
class ProgressSummary {
  /// The total value achieved so far.
  final double completedValue;

  /// The target value to be achieved.
  final double targetValue;

  /// The percentage of completion (0.0 to 100.0).
  final double percentage;

  /// The remaining value to reach the target.
  final double remaining;

  /// Whether the target has been reached or exceeded.
  final bool isCompleted;

  /// The date when the goal was completed, if applicable.
  final DateTime? completionDate;

  /// Creates an immutable [ProgressSummary].
  const ProgressSummary({
    required this.completedValue,
    required this.targetValue,
    required this.percentage,
    required this.remaining,
    required this.isCompleted,
    this.completionDate,
  });

  /// Factory for creating an empty or zero progress summary.
  factory ProgressSummary.zero(double targetValue) {
    return ProgressSummary(
      completedValue: 0,
      targetValue: targetValue,
      percentage: 0,
      remaining: targetValue,
      isCompleted: false,
    );
  }
}
