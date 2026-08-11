/// [NotificationType] defines the different categories of notifications in HabitFlow.
enum NotificationType {
  /// Notifications related to leaderboard changes or rankings.
  leaderboard,

  /// Notifications for parents to approve a child's reward or habit completion.
  rewardApproval,

  /// Reminders for active or upcoming challenges.
  challengeReminder,

  /// Insights or behavioral alerts from the intelligence engine.
  intelligence,

  /// Standard habit reminders (legacy/existing).
  habitReminder,

  /// System-level notifications or generic alerts.
  system,
}
