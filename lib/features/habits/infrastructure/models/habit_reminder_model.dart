import 'package:flutter/material.dart';
import '../../domain/entities/habit_reminder.dart';

/// [HabitReminderModel] is the data transfer object for [HabitReminder].
/// It handles serialization for SharedPreferences and Firestore.
class HabitReminderModel {
  /// The unique identifier for this reminder.
  final String id;

  /// The ID of the habit this reminder belongs to.
  final String habitId;

  /// Whether the reminder is enabled.
  final bool enabled;

  /// The hour the reminder triggers.
  final int hour;

  /// The minute the reminder triggers.
  final int minute;

  /// The weekdays this reminder is active for.
  final List<int> weekdays;

  /// The repeat strategy.
  final String repeatType;

  /// The notification title.
  final String notificationTitle;

  /// The notification body.
  final String notificationBody;

  /// When this reminder was created.
  final String createdAt;

  /// When this reminder was last updated.
  final String updatedAt;

  /// Creates a [HabitReminderModel].
  const HabitReminderModel({
    required this.id,
    required this.habitId,
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.weekdays,
    required this.repeatType,
    required this.notificationTitle,
    required this.notificationBody,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a model from a JSON map.
  factory HabitReminderModel.fromJson(Map<String, dynamic> json) {
    return HabitReminderModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      enabled: json['enabled'] as bool,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      weekdays: (json['weekdays'] as List).cast<int>(),
      repeatType: json['repeatType'] as String,
      notificationTitle: json['notificationTitle'] as String,
      notificationBody: json['notificationBody'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
      'weekdays': weekdays,
      'repeatType': repeatType,
      'notificationTitle': notificationTitle,
      'notificationBody': notificationBody,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a model from a domain entity.
  factory HabitReminderModel.fromEntity(HabitReminder entity) {
    return HabitReminderModel(
      id: entity.id,
      habitId: entity.habitId,
      enabled: entity.enabled,
      hour: entity.timeOfDay.hour,
      minute: entity.timeOfDay.minute,
      weekdays: entity.weekdays,
      repeatType: entity.repeatType.name,
      notificationTitle: entity.notificationTitle,
      notificationBody: entity.notificationBody,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Converts the model to a domain entity.
  HabitReminder toEntity() {
    return HabitReminder(
      id: id,
      habitId: habitId,
      enabled: enabled,
      timeOfDay: TimeOfDay(hour: hour, minute: minute),
      weekdays: weekdays,
      repeatType: ReminderRepeatType.values.byName(repeatType),
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
