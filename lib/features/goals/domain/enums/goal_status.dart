/// Represents the current lifecycle state of a goal.
enum GoalStatus {
  /// Goal is currently being tracked.
  active,

  /// Goal has been successfully completed.
  completed,

  /// Goal tracking is temporarily suspended.
  paused,

  /// Goal is archived and no longer shown in active lists.
  archived,

  /// Goal time period has ended without completion.
  expired,
}
