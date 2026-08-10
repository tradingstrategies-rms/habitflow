/// Defines the time period or scope of a goal.
enum GoalScope {
  /// Goal to be achieved within a single day.
  daily,

  /// Goal to be achieved within a week.
  weekly,

  /// Goal to be achieved within a month.
  monthly,

  /// Goal with a custom time frame.
  custom,
}
