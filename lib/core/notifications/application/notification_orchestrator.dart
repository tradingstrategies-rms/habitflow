import 'dart:async';

import '../domain/notification_payload.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_service.dart';

/// [NotificationOrchestrator] is responsible for routing notifications to the 
/// appropriate delivery service based on user preferences and context.
class NotificationOrchestrator {
  final NotificationService _notificationService;
  final NotificationPreferences _preferences;

  NotificationOrchestrator({
    required NotificationService notificationService,
    required NotificationPreferences preferences,
    // ignore: prefer_initializing_formals
  }) : _notificationService = notificationService,
       // ignore: prefer_initializing_formals
       _preferences = preferences;

  /// Processes a notification request.
  /// Returns true if the notification was delivered or scheduled, false otherwise.
  Future<bool> notify(NotificationPayload payload) async {
    // 1. Check user preferences for this notification type
    if (!_preferences.isEnabled(payload.type)) {
      return false;
    }

    // 2. Check permissions
    final status = await _notificationService.getPermissionStatus();
    // If not determined, we might want to request it, but the requirement says 
    // "Do not automatically spam permission prompts."
    // So we just check if it's denied.
    if (status == NotificationPermissionStatus.denied) {
      return false;
    }

    // 3. Deliver via the service
    // Note: Deduplication is handled by using a stable stable identifier (payload.id)
    // which maps to a consistent intId in the service implementation.
    await _notificationService.deliver(payload);
    return true;
  }

  /// Cancels a notification by its stable ID.
  Future<void> cancel(String id) async {
    await _notificationService.cancel(id);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _notificationService.cancelAll();
  }
}
