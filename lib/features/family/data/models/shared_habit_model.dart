import '../../domain/entities/shared_habit.dart';
import '../../domain/enums/shared_habit_completion_mode.dart';

class SharedHabitModel extends SharedHabit {
  const SharedHabitModel({
    required super.id,
    required super.habitId,
    required super.assignedMemberIds,
    required super.completionMode,
    required super.createdBy,
    required super.createdAt,
  });

  factory SharedHabitModel.fromEntity(SharedHabit entity) {
    return SharedHabitModel(
      id: entity.id,
      habitId: entity.habitId,
      assignedMemberIds: entity.assignedMemberIds,
      completionMode: entity.completionMode,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }

  factory SharedHabitModel.fromJson(Map<String, dynamic> json) {
    return SharedHabitModel(
      id: json['id']?.toString() ?? '',
      habitId: json['habitId']?.toString() ?? '',
      assignedMemberIds: (json['assignedMemberIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      completionMode: json['completionMode'] != null
          ? SharedHabitCompletionMode.values.firstWhere(
              (e) => e.name == json['completionMode'].toString(),
              orElse: () => SharedHabitCompletionMode.everyone,
            )
          : SharedHabitCompletionMode.everyone,
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'assignedMemberIds': assignedMemberIds,
      'completionMode': completionMode.name,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
