import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/notification_payload.dart';
import '../domain/notification_preferences.dart';
import '../domain/notification_service.dart';
import '../domain/notification_type.dart';

/// [NotificationOrchestrator] is responsible for routing notifications to the 
/// appropriate delivery service based on user preferences and context.
class NotificationOrchestrator {
  final NotificationService _notificationService;
  final NotificationPreferences _preferences;

  NotificationOrchestrator({
    required NotificationService notificationService,
    required NotificationPreferences preferences,
  }) : _notificationService = notificationService,
       _preferences = preferences;

  /// Processes a notification request.
  /// Returns true if the notification was delivered or scheduled, false otherwise.
  Future<bool> notify(NotificationPayload payload) async {
    // 1. Validate payload
    if (!_validatePayload(payload)) {
      debugPrint('NotificationOrchestrator: Invalid payload for ID ${payload.id}');
      return false;
    }

    // 2. Check user preferences for this notification type
    if (!_preferences.isEnabled(payload.type)) {
      debugPrint('NotificationOrchestrator: Type ${payload.type} is disabled by preferences');
      return false;
    }

    // 3. Check permissions
    final status = await _notificationService.getPermissionStatus();
    if (status == NotificationPermissionStatus.denied) {
      debugPrint('NotificationOrchestrator: Permission denied for notifications');
      return false;
    }

    // 4. Deliver via the service
    // Note: Deduplication is handled by using a stable stable identifier (payload.id)
    // which maps to a consistent intId in the service implementation.
    try {
      await _notificationService.deliver(payload);
      return true;
    } catch (e) {
      debugPrint('NotificationOrchestrator: Delivery failure for ID ${payload.id}: $e');
      return false;
    }
  }

  bool _validatePayload(NotificationPayload payload) {
    if (payload.id.isEmpty) return false;
    if (payload.title.isEmpty && payload.body.isEmpty) return false;
    
    // Engagement notifications in Sprint 9.2 should always be profile-scoped.
    // Standard system or legacy notifications might not have it yet.
    if (payload.type != NotificationType.system && 
        payload.type != NotificationType.habitReminder) {
      if (payload.recipientProfileId == null || payload.recipientProfileId!.isEmpty) {
        debugPrint('NotificationOrchestrator: Engagement notification ${payload.id} missing recipientProfileId');
        return false;
      }
    }

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
