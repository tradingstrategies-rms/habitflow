import 'package:flutter/foundation.dart';

/// [MissedHabitEvent] represents an occurrence where a habit reminder was triggered
/// but no completion was recorded within the grace period.
@immutable
class MissedHabitEvent {
  /// The ID of the habit associated with the missed event.
  final String habitId;

  /// The ID of the specific reminder that was missed.
  final String reminderId;

  /// The original time the reminder was scheduled for.
  final DateTime scheduledTime;

  /// When this missed event was detected.
  final DateTime detectedAt;

  /// Whether the user has acknowledged this missed event.
  final bool acknowledged;

  /// Creates a [MissedHabitEvent].
  const MissedHabitEvent({
    required this.habitId,
    required this.reminderId,
    required this.scheduledTime,
    required this.detectedAt,
    this.acknowledged = false,
  });

  /// Creates a copy of this event with replaced fields.
  MissedHabitEvent copyWith({
    String? habitId,
    String? reminderId,
    DateTime? scheduledTime,
    DateTime? detectedAt,
    bool? acknowledged,
  }) {
    return MissedHabitEvent(
      habitId: habitId ?? this.habitId,
      reminderId: reminderId ?? this.reminderId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      detectedAt: detectedAt ?? this.detectedAt,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MissedHabitEvent &&
          runtimeType == other.runtimeType &&
          habitId == other.habitId &&
          reminderId == other.reminderId &&
          scheduledTime == other.scheduledTime &&
          detectedAt == other.detectedAt &&
          acknowledged == other.acknowledged;

  @override
  int get hashCode =>
      habitId.hashCode ^
      reminderId.hashCode ^
      scheduledTime.hashCode ^
      detectedAt.hashCode ^
      acknowledged.hashCode;
}
