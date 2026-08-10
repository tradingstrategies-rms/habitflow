import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/router/app_router.dart';
import '../services/notification_router_service.dart';

/// Provider for [NotificationRouterService].
final notificationRouterServiceProvider = Provider<NotificationRouterService>((ref) {
  final router = ref.watch(routerProvider);
  return NotificationRouterService(router);
});
