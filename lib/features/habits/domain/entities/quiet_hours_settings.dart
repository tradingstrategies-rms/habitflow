import 'package:flutter/material.dart';

/// [QuietHoursSettings] represents the user's preferences for notification-free periods.
@immutable
class QuietHoursSettings {
  /// Whether quiet hours are enforced.
  final bool enabled;

  /// The start time of the quiet period.
  final TimeOfDay startTime;

  /// The end time of the quiet period.
  final TimeOfDay endTime;

  /// Creates a [QuietHoursSettings] instance.
  const QuietHoursSettings({
    required this.enabled,
    required this.startTime,
    required this.endTime,
  });

  /// Default settings: Disabled, 10 PM to 8 AM.
  factory QuietHoursSettings.initial() => const QuietHoursSettings(
        enabled: false,
        startTime: TimeOfDay(hour: 22, minute: 0),
        endTime: TimeOfDay(hour: 8, minute: 0),
      );

  /// Creates a copy of these settings with replaced fields.
  QuietHoursSettings copyWith({
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return QuietHoursSettings(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuietHoursSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => enabled.hashCode ^ startTime.hashCode ^ endTime.hashCode;
}
