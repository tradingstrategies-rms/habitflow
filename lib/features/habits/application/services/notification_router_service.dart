import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';

/// [NotificationRouterService] handles navigation when a notification is tapped.
class NotificationRouterService {
  final GoRouter _router;

  /// Creates a [NotificationRouterService].
  NotificationRouterService(this._router);

  /// Navigates to the corresponding screen based on the [payload].
  void handleNotificationPayloadTap(NotificationPayload payload) {
    debugPrint('NotificationRouterService: Handling tap for ID ${payload.id}, route: ${payload.route}');

    if (payload.route != null && payload.route!.isNotEmpty) {
      try {
        _router.push(payload.route!);
        return;
      } catch (e) {
        debugPrint('NotificationRouterService: Failed to push route ${payload.route}: $e');
        // Fallback to dashboard if route fails
        _router.goNamed(RouteNames.dashboard);
        return;
      }
    }

    // Fallback to metadata for habitId (Legacy or Metadata-based)
    final habitId = payload.metadata?['habitId'];
    if (habitId != null) {
      _router.pushNamed(
        RouteNames.habitDetails,
        pathParameters: {'habitId': habitId},
      );
      return;
    }

    // Default fallback
    _router.goNamed(RouteNames.dashboard);
  }

  /// Parses the notification [payload] and navigates to the corresponding screen.
  void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // 1. Handle explicit route in payload
      final route = data['route'] as String?;
      if (route != null && route.isNotEmpty) {
        _router.push(route);
        return;
      }

      // 2. Fallback to legacy habitId handling
      final habitId = data['habitId'] as String?;
      if (habitId != null) {
        _router.pushNamed(
          RouteNames.habitDetails,
          pathParameters: {'habitId': habitId},
        );
        return;
      }
    } catch (e) {
      debugPrint('NotificationRouterService: Malformed JSON payload: $e');
    }

    // Fallback
    _router.goNamed(RouteNames.dashboard);
  }
}
