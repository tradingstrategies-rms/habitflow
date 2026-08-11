import 'notification_payload.dart';

/// [NotificationPermissionStatus] defines the user's current permission state.
enum NotificationPermissionStatus {
  granted,
  denied,
  notDetermined,
}

/// [NotificationService] is the platform-independent interface for delivering notifications.
abstract class NotificationService {
  /// Initializes the service.
  Future<void> initialize(void Function(NotificationPayload) onNotificationTap);

  /// Requests permissions from the user.
  Future<NotificationPermissionStatus> requestPermission();

  /// Gets the current permission status.
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Delivers or schedules a notification.
  Future<void> deliver(NotificationPayload payload);

  /// Cancels a specific notification by its stable ID.
  Future<void> cancel(String id);

  /// Cancels all scheduled notifications.
  Future<void> cancelAll();
}
