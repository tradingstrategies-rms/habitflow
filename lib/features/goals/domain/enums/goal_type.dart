/// Defines the type of target tracking for a goal.
enum GoalType {
  /// Tracked by the number of successful completions.
  completionCount,

  /// Tracked by the consecutive number of successful days.
  streak,

  /// Tracked by a percentage of completion (0-100).
  percentage,

  /// Tracked by a simple yes/no status.
  binary,

  /// Tracked by a specific numeric value.
  numeric,
}
