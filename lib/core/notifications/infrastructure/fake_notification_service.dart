import '../domain/notification_payload.dart';
import '../domain/notification_service.dart';

/// [FakeNotificationService] is a mock implementation for testing.
class FakeNotificationService implements NotificationService {
  final List<NotificationPayload> deliveredNotifications = [];
  final List<String> cancelledNotifications = [];
  bool allCancelled = false;
  NotificationPermissionStatus permissionStatus = NotificationPermissionStatus.granted;

  @override
  Future<void> initialize(void Function(NotificationPayload) onNotificationTap) async {
    // No-op for fake
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    return permissionStatus;
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return permissionStatus;
  }

  @override
  Future<void> deliver(NotificationPayload payload) async {
    deliveredNotifications.add(payload);
  }

  @override
  Future<void> cancel(String id) async {
    cancelledNotifications.add(id);
  }

  @override
  Future<void> cancelAll() async {
    allCancelled = true;
  }

  void reset() {
    deliveredNotifications.clear();
    cancelledNotifications.clear();
    allCancelled = false;
  }
}
