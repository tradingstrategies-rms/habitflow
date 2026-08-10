import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habit_repository_provider.dart';
import 'quiet_hours_providers.dart';
import 'notification_router_providers.dart';
import '../services/reminder_scheduler_service.dart';
import '../services/reminder_snooze_service.dart';
import '../../infrastructure/notifications/local_notification_adapter.dart';

/// Provider for [LocalNotificationAdapter].
final localNotificationAdapterProvider = Provider<LocalNotificationAdapter>((ref) {
  return LocalNotificationAdapter();
});

/// Provider for [ReminderSchedulerService].
final reminderSchedulerServiceProvider = Provider<ReminderSchedulerService>((ref) {
  final adapter = ref.watch(localNotificationAdapterProvider);
  final repository = ref.watch(reminderRepositoryProvider);
  final quietHours = ref.watch(quietHoursPolicyServiceProvider);
  final notificationRouter = ref.watch(notificationRouterServiceProvider);
  return ReminderSchedulerService(adapter, repository, quietHours, notificationRouter);
});

/// Provider for [ReminderSnoozeService].
final reminderSnoozeServiceProvider = Provider<ReminderSnoozeService>((ref) {
  final adapter = ref.watch(localNotificationAdapterProvider);
  return ReminderSnoozeService(adapter);
});
