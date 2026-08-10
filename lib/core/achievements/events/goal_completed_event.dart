/// [GoalCompletedEvent] is an immutable event triggered when a goal reaches completion.
class GoalCompletedEvent {
  /// Unique identifier of the completed goal.
  final String goalId;

  /// Title of the goal.
  final String goalTitle;

  /// When the goal was marked as completed.
  final DateTime completedAt;

  /// The target value that was achieved.
  final double targetValue;

  /// A motivating message for the user.
  final String achievementMessage;

  const GoalCompletedEvent({
    required this.goalId,
    required this.goalTitle,
    required this.completedAt,
    required this.targetValue,
    required this.achievementMessage,
  });
}
