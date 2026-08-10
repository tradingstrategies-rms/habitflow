import 'package:flutter/foundation.dart';
import '../enums/shared_habit_completion_mode.dart';

@immutable
class SharedHabit {
  final String id;
  final String habitId;
  final List<String> assignedMemberIds;
  final SharedHabitCompletionMode completionMode;
  final String createdBy;
  final DateTime createdAt;

  const SharedHabit({
    required this.id,
    required this.habitId,
    required this.assignedMemberIds,
    required this.completionMode,
    required this.createdBy,
    required this.createdAt,
  });

  SharedHabit copyWith({
    String? id,
    String? habitId,
    List<String>? assignedMemberIds,
    SharedHabitCompletionMode? completionMode,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return SharedHabit(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
      completionMode: completionMode ?? this.completionMode,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedHabit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          habitId == other.habitId &&
          listEquals(assignedMemberIds, other.assignedMemberIds) &&
          completionMode == other.completionMode &&
          createdBy == other.createdBy &&
          createdAt == other.createdAt);

  @override
  int get hashCode =>
      id.hashCode ^
      habitId.hashCode ^
      assignedMemberIds.hashCode ^
      completionMode.hashCode ^
      createdBy.hashCode ^
      createdAt.hashCode;
}
