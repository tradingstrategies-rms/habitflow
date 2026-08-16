import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_preferences.dart';
import 'package:habitflow/core/notifications/domain/notification_service.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/notifications/infrastructure/fake_notification_service.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late FakeNotificationService fakeService;
  late NotificationOrchestrator orchestrator;

  setUpAll(() {
    registerFallbackValue(const NotificationPayload(
      id: '',
      title: '',
      body: '',
      type: NotificationType.system,
    ));
  });

  setUp(() {
    fakeService = FakeNotificationService();
  });

  group('NotificationOrchestrator Hardening', () {
    test('should reject payload with empty ID', () async {
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: const NotificationPreferences(),
      );

      const payload = NotificationPayload(
        id: '',
        title: 'Title',
        body: 'Body',
        type: NotificationType.intelligence,
        recipientProfileId: 'p1',
      );

      final result = await orchestrator.notify(payload);

      expect(result, false);
      expect(fakeService.deliveredNotifications.isEmpty, true);
    });

    test('should reject engagement notification missing recipientProfileId', () async {
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: const NotificationPreferences(),
      );

      const payload = NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.intelligence,
        recipientProfileId: null,
      );

      final result = await orchestrator.notify(payload);

      expect(result, false);
      expect(fakeService.deliveredNotifications.isEmpty, true);
    });

    test('should allow legacy habit reminder without recipientProfileId', () async {
      orchestrator = NotificationOrchestrator(
        notificationService: fakeService,
        preferences: const NotificationPreferences(),
      );

      const payload = NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.habitReminder,
      );

      final result = await orchestrator.notify(payload);

      expect(result, true);
      expect(fakeService.deliveredNotifications.length, 1);
    });

    test('should handle delivery service exceptions gracefully', () async {
      final mockService = MockNotificationService();
      when(() => mockService.getPermissionStatus()).thenAnswer((_) async => NotificationPermissionStatus.granted);
      when(() => mockService.deliver(any())).thenThrow(Exception('Platform error'));

      orchestrator = NotificationOrchestrator(
        notificationService: mockService,
        preferences: const NotificationPreferences(),
      );

      registerFallbackValue(const NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.system,
      ));

      final result = await orchestrator.notify(const NotificationPayload(
        id: 'test_1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.system,
      ));

      expect(result, false);
    });
  });
}

class MockNotificationService extends Mock implements NotificationService {}
