/// [NotificationHistoryRepository] defines the interface for tracking delivered notifications.
/// Used for deduplication and ensuring users aren't spammed with the same intelligence insight.
abstract class NotificationHistoryRepository {
  /// Checks if a notification with the given ID has already been delivered.
  Future<bool> hasBeenSent(String id);

  /// Marks a notification ID as delivered.
  Future<void> markAsSent(String id);

  /// Clears the history.
  Future<void> clear();
}
