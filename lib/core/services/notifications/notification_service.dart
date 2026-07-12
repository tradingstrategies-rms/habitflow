/// [NotificationService] defines the interface for local and push notifications.
abstract class NotificationService {
  /// Initializes the notification service.
  Future<void> initialize();

  /// Schedules a local notification.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  });

  /// Cancels a specific notification by ID.
  Future<void> cancel(int id);

  /// Cancels all scheduled notifications.
  Future<void> cancelAll();

  /// Requests permission to show notifications.
  Future<bool> requestPermission();
}

/// [NoOpNotificationService] is a placeholder implementation.
class NoOpNotificationService implements NotificationService {
  // TODO: Implement LocalNotificationService (flutter_local_notifications) 
  // and FirebaseMessagingService in later sprints.
  
  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool> requestPermission() async => true;
}
