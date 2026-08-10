import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/entities/habit_reminder.dart';
import '../../infrastructure/notifications/local_notification_adapter.dart';
import '../services/quiet_hours_policy_service.dart';
import '../services/notification_router_service.dart';

/// [ReminderSchedulerService] manages the scheduling of habit reminders.
/// It acts as a bridge between the domain and the notification infrastructure.
class ReminderSchedulerService {
  final LocalNotificationAdapter _notificationAdapter;
  final ReminderRepository _repository;
  final QuietHoursPolicyService _quietHoursPolicy;
  final NotificationRouterService _notificationRouter;

  /// Creates a [ReminderSchedulerService].
  ReminderSchedulerService(
    this._notificationAdapter,
    this._repository,
    this._quietHoursPolicy,
    this._notificationRouter,
  );

  /// Initializes the scheduling engine and requests permissions.
  Future<void> initialize() async {
    await _notificationAdapter.initialize(_notificationRouter.handleNotificationTap);
    await _notificationAdapter.requestPermissions();
  }

  /// Schedules all notifications for a given reminder based on its repeat type.
  Future<void> scheduleReminder(HabitReminder reminder) async {
    debugPrint('ReminderSchedulerService: scheduleReminder called for habit: ${reminder.habitId}, enabled: ${reminder.enabled}');
    if (!reminder.enabled) {
      await cancelReminder(reminder);
      return;
    }

    final title = reminder.notificationTitle.isEmpty 
        ? 'Time for your habit' 
        : reminder.notificationTitle;
    final body = reminder.notificationBody.isEmpty 
        ? 'Stay consistent and keep your streak alive.' 
        : reminder.notificationBody;

    final payload = jsonEncode({
      'habitId': reminder.habitId,
      'reminderId': reminder.id,
    });

    switch (reminder.repeatType) {
      case ReminderRepeatType.daily:
        final scheduledTime = await _getEffectiveTime(reminder.timeOfDay);
        await _notificationAdapter.scheduleDaily(
          id: _generateId(reminder.habitId, 0),
          title: title,
          body: body,
          time: TimeOfDay.fromDateTime(scheduledTime),
          payload: payload,
        );
        break;
      case ReminderRepeatType.selectedWeekdays:
        for (int weekday = 1; weekday <= 7; weekday++) {
          final id = _generateId(reminder.habitId, weekday);
          if (reminder.weekdays.contains(weekday)) {
            final scheduledTime = await _getEffectiveTime(reminder.timeOfDay);
            await _notificationAdapter.scheduleWeekly(
              id: id,
              title: title,
              body: body,
              time: TimeOfDay.fromDateTime(scheduledTime),
              weekday: weekday,
              payload: payload,
            );
          } else {
            await _notificationAdapter.cancel(id);
          }
        }
        break;
      case ReminderRepeatType.once:
        final scheduledTime = await _getEffectiveTime(reminder.timeOfDay);
        await _notificationAdapter.scheduleOnce(
          id: _generateId(reminder.habitId, 0),
          title: title,
          body: body,
          time: TimeOfDay.fromDateTime(scheduledTime),
          payload: payload,
        );
        break;
    }
  }

  Future<DateTime> _getEffectiveTime(TimeOfDay original) async {
    final now = DateTime.now();
    final intended = DateTime(now.year, now.month, now.day, original.hour, original.minute);
    return await _quietHoursPolicy.nextAllowedTime(intended);
  }

  /// Cancels all notifications associated with a reminder.
  Future<void> cancelReminder(HabitReminder reminder) async {
    if (reminder.repeatType == ReminderRepeatType.selectedWeekdays) {
      for (int weekday = 1; weekday <= 7; weekday++) {
        await _notificationAdapter.cancel(_generateId(reminder.habitId, weekday));
      }
    } else {
      await _notificationAdapter.cancel(_generateId(reminder.habitId, 0));
    }
  }

  /// Reschedules a reminder by canceling existing notifications and creating new ones.
  Future<void> rescheduleReminder(HabitReminder reminder) async {
    await cancelReminder(reminder);
    await scheduleReminder(reminder);
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAll() async {
    await _notificationAdapter.cancelAll();
  }

  /// Reschedules all enabled reminders from the repository.
  Future<void> rescheduleAll() async {
    await cancelAll();
    final reminders = await _repository.getReminders();
    for (final reminder in reminders) {
      if (reminder.enabled) {
        await scheduleReminder(reminder);
      }
    }
  }

  /// Deterministically generates a notification ID.
  int _generateId(String habitId, int weekday) {
    // We use a combination of habitId and weekday to ensure unique IDs
    // for multiple notifications from the same habit (e.g. weekly reminders).
    // Using absolute value to ensure it's a valid positive integer for notifications.
    return Object.hash(habitId, weekday).abs();
  }
}
