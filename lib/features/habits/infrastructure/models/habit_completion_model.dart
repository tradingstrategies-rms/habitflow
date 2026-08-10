import '../../domain/entities/habit_completion.dart';

class HabitCompletionModel {
  final String id;
  final String habitId;
  final String? profileId;
  final String completionDate;
  final bool completed;
  final String completedAt;
  final String createdAt;

  const HabitCompletionModel({
    required this.id,
    required this.habitId,
    this.profileId,
    required this.completionDate,
    required this.completed,
    required this.completedAt,
    required this.createdAt,
  });

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) => HabitCompletionModel(
        id: json['id'] as String,
        habitId: json['habitId'] as String,
        profileId: json['profileId'] as String?,
        completionDate: json['completionDate'] as String,
        completed: json['completed'] as bool,
        completedAt: json['completedAt'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'habitId': habitId,
        'profileId': profileId,
        'completionDate': completionDate,
        'completed': completed,
        'completedAt': completedAt,
        'createdAt': createdAt,
      };

  factory HabitCompletionModel.fromEntity(HabitCompletion entity) => HabitCompletionModel(
        id: entity.id,
        habitId: entity.habitId,
        profileId: entity.profileId,
        completionDate: entity.completionDate.toIso8601String(),
        completed: entity.completed,
        completedAt: entity.completedAt.toIso8601String(),
        createdAt: entity.createdAt.toIso8601String(),
      );

  HabitCompletion toEntity() => HabitCompletion(
        id: id,
        habitId: habitId,
        profileId: profileId,
        completionDate: DateTime.parse(completionDate),
        completed: completed,
        completedAt: DateTime.parse(completedAt),
        createdAt: DateTime.parse(createdAt),
      );
}
