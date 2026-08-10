import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Defines how often a reminder should repeat.
enum ReminderRepeatType {
  /// Repeats every day.
  daily,

  /// Repeats only on specific weekdays.
  selectedWeekdays,

  /// Occurs only once.
  once,
}

/// [HabitReminder] represents the domain entity for a habit reminder.
/// It is independent of any notification scheduling logic.
@immutable
class HabitReminder {
  /// The unique identifier for this reminder.
  final String id;

  /// The ID of the habit this reminder belongs to.
  final String habitId;

  /// Whether the reminder is currently enabled.
  final bool enabled;

  /// The time of day the reminder should trigger.
  final TimeOfDay timeOfDay;

  /// The weekdays this reminder is active for (1 = Monday, 7 = Sunday).
  final List<int> weekdays;

  /// The repeat strategy for this reminder.
  final ReminderRepeatType repeatType;

  /// The title to be displayed in the notification.
  final String notificationTitle;

  /// The body text to be displayed in the notification.
  final String notificationBody;

  /// When this reminder was created.
  final DateTime createdAt;

  /// When this reminder was last updated.
  final DateTime updatedAt;

  /// Creates a [HabitReminder].
  const HabitReminder({
    required this.id,
    required this.habitId,
    required this.enabled,
    required this.timeOfDay,
    required this.weekdays,
    required this.repeatType,
    required this.notificationTitle,
    required this.notificationBody,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this [HabitReminder] with the given fields replaced.
  HabitReminder copyWith({
    String? id,
    String? habitId,
    bool? enabled,
    TimeOfDay? timeOfDay,
    List<int>? weekdays,
    ReminderRepeatType? repeatType,
    String? notificationTitle,
    String? notificationBody,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitReminder(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      enabled: enabled ?? this.enabled,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      weekdays: weekdays ?? this.weekdays,
      repeatType: repeatType ?? this.repeatType,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationBody: notificationBody ?? this.notificationBody,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitReminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          enabled == other.enabled &&
          timeOfDay == other.timeOfDay &&
          listEquals(weekdays, other.weekdays) &&
          repeatType == other.repeatType &&
          notificationTitle == other.notificationTitle &&
          notificationBody == other.notificationBody &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      enabled.hashCode ^
      timeOfDay.hashCode ^
      weekdays.hashCode ^
      repeatType.hashCode ^
      notificationTitle.hashCode ^
      notificationBody.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
