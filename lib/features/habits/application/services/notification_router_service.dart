import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:habitflow/core/router/route_names.dart';

/// [NotificationRouterService] handles navigation when a notification is tapped.
class NotificationRouterService {
  final GoRouter _router;

  /// Creates a [NotificationRouterService].
  NotificationRouterService(this._router);

  /// Parses the notification [payload] and navigates to the corresponding screen.
  void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final habitId = data['habitId'] as String?;

      if (habitId != null) {
        _router.pushNamed(
          RouteNames.habitDetails,
          pathParameters: {'habitId': habitId},
        );
      }
    } catch (_) {
      // Gracefully ignore invalid payloads
    }
  }
}
