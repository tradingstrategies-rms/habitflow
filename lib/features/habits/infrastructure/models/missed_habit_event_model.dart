import '../../domain/entities/missed_habit_event.dart';

/// [MissedHabitEventModel] handles serialization for [MissedHabitEvent].
class MissedHabitEventModel {
  final String habitId;
  final String reminderId;
  final String scheduledTime;
  final String detectedAt;
  final bool acknowledged;

  const MissedHabitEventModel({
    required this.habitId,
    required this.reminderId,
    required this.scheduledTime,
    required this.detectedAt,
    required this.acknowledged,
  });

  factory MissedHabitEventModel.fromJson(Map<String, dynamic> json) => MissedHabitEventModel(
        habitId: json['habitId'] as String,
        reminderId: json['reminderId'] as String,
        scheduledTime: json['scheduledTime'] as String,
        detectedAt: json['detectedAt'] as String,
        acknowledged: json['acknowledged'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'reminderId': reminderId,
        'scheduledTime': scheduledTime,
        'detectedAt': detectedAt,
        'acknowledged': acknowledged,
      };

  factory MissedHabitEventModel.fromEntity(MissedHabitEvent entity) => MissedHabitEventModel(
        habitId: entity.habitId,
        reminderId: entity.reminderId,
        scheduledTime: entity.scheduledTime.toIso8601String(),
        detectedAt: entity.detectedAt.toIso8601String(),
        acknowledged: entity.acknowledged,
      );

  MissedHabitEvent toEntity() => MissedHabitEvent(
        habitId: habitId,
        reminderId: reminderId,
        scheduledTime: DateTime.parse(scheduledTime),
        detectedAt: DateTime.parse(detectedAt),
        acknowledged: acknowledged,
      );
}
