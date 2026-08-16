import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_preferences.dart';
import 'package:habitflow/core/notifications/domain/notification_service.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/notifications/infrastructure/fake_notification_service.dart';

void main() {
  late FakeNotificationService fakeService;
  late NotificationOrchestrator orchestrator;

  setUp(() {
    fakeService = FakeNotificationService();
  });

  group('NotificationOrchestrator', () {
    test('should deliver notification when enabled and permitted', () async {
      const prefs = NotificationPreferences(enabledTypes: {
        NotificationType.leaderboard: true,
      });
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: prefs,
      );

      const payload = NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.leaderboard,
        recipientProfileId: 'p1',
      );

      final result = await orchestrator.notify(payload);

      expect(result, true);
      expect(fakeService.deliveredNotifications.length, 1);
      expect(fakeService.deliveredNotifications.first.id, 'test_1');
    });

    test('should NOT deliver notification when type is disabled in preferences', () async {
      const prefs = NotificationPreferences(enabledTypes: {
        NotificationType.leaderboard: false,
      });
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: prefs,
      );

      const payload = NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.leaderboard,
        recipientProfileId: 'p1',
      );

      final result = await orchestrator.notify(payload);

      expect(result, false);
      expect(fakeService.deliveredNotifications.isEmpty, true);
    });

    test('should NOT deliver notification when permission is denied', () async {
      const prefs = NotificationPreferences();
      fakeService.permissionStatus = NotificationPermissionStatus.denied;
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: prefs,
      );

      const payload = NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.leaderboard,
        recipientProfileId: 'p1',
      );

      final result = await orchestrator.notify(payload);

      expect(result, false);
      expect(fakeService.deliveredNotifications.isEmpty, true);
    });

    test('should cancel notification', () async {
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: const NotificationPreferences(),
      );

      await orchestrator.cancel('test_id');

      expect(fakeService.cancelledNotifications.contains('test_id'), true);
    });

    test('should cancel all notifications', () async {
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: const NotificationPreferences(),
      );

      await orchestrator.cancelAll();

      expect(fakeService.allCancelled, true);
    });
  });
}
