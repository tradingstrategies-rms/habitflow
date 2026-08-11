import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_priority.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/notifications/domain/notification_preferences.dart';

void main() {
  group('NotificationPayload', () {
    test('should correctly serialize to and from JSON', () {
      final payload = NotificationPayload(
        id: 'test_id',
        title: 'Test Title',
        body: 'Test Body',
        type: NotificationType.leaderboard,
        priority: NotificationPriority.high,
        scheduledAt: DateTime(2026, 8, 11, 10, 0),
        route: '/test/route',
        metadata: const {'key': 'value'},
        recipientProfileId: 'profile_123',
        familyId: 'family_456',
      );

      final json = payload.toJson();
      final fromJson = NotificationPayload.fromJson(json);

      expect(fromJson, payload);
      expect(fromJson.id, 'test_id');
      expect(fromJson.title, 'Test Title');
      expect(fromJson.type, NotificationType.leaderboard);
      expect(fromJson.priority, NotificationPriority.high);
      expect(fromJson.scheduledAt, DateTime(2026, 8, 11, 10, 0));
      expect(fromJson.route, '/test/route');
      expect(fromJson.metadata?['key'], 'value');
      expect(fromJson.recipientProfileId, 'profile_123');
      expect(fromJson.familyId, 'family_456');
    });

    test('should have a stable integer ID', () {
      const payload1 = NotificationPayload(
        id: 'test_id',
        title: 'Title 1',
        body: 'Body 1',
        type: NotificationType.system,
      );
      const payload2 = NotificationPayload(
        id: 'test_id',
        title: 'Title 2',
        body: 'Body 2',
        type: NotificationType.leaderboard,
      );

      expect(payload1.intId, payload2.intId);
    });
  });

  group('NotificationPreferences', () {
    test('should default to enabled if not specified', () {
      const prefs = NotificationPreferences();
      expect(prefs.isEnabled(NotificationType.leaderboard), true);
      expect(prefs.isEnabled(NotificationType.rewardApproval), true);
    });

    test('should correctly report enabled/disabled status', () {
      const prefs = NotificationPreferences(enabledTypes: {
        NotificationType.leaderboard: true,
        NotificationType.intelligence: false,
      });

      expect(prefs.isEnabled(NotificationType.leaderboard), true);
      expect(prefs.isEnabled(NotificationType.intelligence), false);
      expect(prefs.isEnabled(NotificationType.system), true); // default
    });
  });
}
