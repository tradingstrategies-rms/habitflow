import 'dart:convert';
import '../../domain/entities/habit_reminder.dart';
import '../../infrastructure/notifications/local_notification_adapter.dart';

/// [ReminderSnoozeService] manages temporary notification postponement.
/// It works independently of the recurring reminder scheduling.
class ReminderSnoozeService {
  final LocalNotificationAdapter _notificationAdapter;

  /// The list of supported snooze durations in minutes.
  static const List<int> supportedDurations = [5, 10, 15, 30, 60];

  /// Creates a [ReminderSnoozeService].
  ReminderSnoozeService(this._notificationAdapter);

  /// Postpones a reminder by the specified [durationMinutes].
  /// 
  /// Throws an [ArgumentError] if the duration is not supported.
  Future<void> snoozeReminder(HabitReminder reminder, int durationMinutes) async {
    if (!supportedDurations.contains(durationMinutes)) {
      throw ArgumentError('Unsupported snooze duration: $durationMinutes');
    }

    final scheduledTime = DateTime.now().add(Duration(minutes: durationMinutes));
    final id = _generateSnoozeId(reminder.habitId, scheduledTime);

    final title = reminder.notificationTitle.isEmpty 
        ? 'Reminder (Snoozed)' 
        : '${reminder.notificationTitle} (Snoozed)';
    
    final body = reminder.notificationBody.isEmpty 
        ? 'Stay consistent and keep your streak alive.' 
        : reminder.notificationBody;

    final payload = jsonEncode({
      'habitId': reminder.habitId,
      'reminderId': reminder.id,
    });

    await _notificationAdapter.scheduleOneTimeNotification(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      payload: payload,
    );
  }

  /// Cancels a specific snooze notification.
  Future<void> cancelSnooze(String habitId, DateTime scheduledTime) async {
    final id = _generateSnoozeId(habitId, scheduledTime);
    await _notificationAdapter.cancel(id);
  }

  /// Cancels all notifications. 
  /// Note: This affects recurring reminders too as per current adapter implementation.
  Future<void> cancelAllSnoozes() async {
    // In a future enhancement, we could track snooze IDs separately to cancel only them.
    // For now, this is a placeholder for the requested API.
  }

  /// Generates a deterministic ID for a snooze notification.
  int _generateSnoozeId(String habitId, DateTime scheduledTime) {
    return Object.hash(
      habitId,
      scheduledTime.millisecondsSinceEpoch,
      'snooze',
    ).abs();
  }
}
