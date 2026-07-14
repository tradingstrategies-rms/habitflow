import '../domain/models/habit.dart';
import '../domain/models/habit_id.dart';
import '../domain/models/habit_frequency.dart';
import '../domain/models/habit_category.dart';
import '../domain/models/habit_difficulty.dart';
import '../domain/models/habit_color.dart';
import '../domain/models/habit_icon.dart';
import '../domain/models/habit_schedule.dart';
import '../domain/models/habit_reminder.dart';

/// [HabitModel] is the DTO for [Habit].
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.category,
    required this.difficulty,
    required this.color,
    required this.icon,
    required this.schedule,
    this.reminders,
    required this.isArchived,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: HabitId(json['id'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      frequency: HabitFrequency.values[json['frequency'] as int],
      category: HabitCategory.values[json['category'] as int],
      difficulty: HabitDifficulty.values[json['difficulty'] as int],
      color: HabitColor(json['color'] as int),
      icon: HabitIcon(json['icon'] as String),
      schedule: HabitSchedule(
        daysOfWeek: (json['schedule']['daysOfWeek'] as List).cast<int>(),
        timeOfDay: json['schedule']['timeOfDay'] != null ? DateTime.parse(json['schedule']['timeOfDay'] as String) : null,
      ),
      reminders: (json['reminders'] as List?)?.map((r) => HabitReminder(
        id: r['id'] as String,
        enabled: r['enabled'] as bool,
        time: DateTime.parse(r['time'] as String),
      )).toList(),
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'title': title,
      'description': description,
      'frequency': frequency.index,
      'category': category.index,
      'difficulty': difficulty.index,
      'color': color.value,
      'icon': icon.value,
      'schedule': {
        'daysOfWeek': schedule.daysOfWeek,
        'timeOfDay': schedule.timeOfDay?.toIso8601String(),
      },
      'reminders': reminders?.map((r) => {
        'id': r.id,
        'enabled': r.enabled,
        'time': r.time.toIso8601String(),
      }).toList(),
      'isArchived': isArchived,
    };
  }

  final HabitId id;
  final String title;
  final String description;
  final HabitFrequency frequency;
  final HabitCategory category;
  final HabitDifficulty difficulty;
  final HabitColor color;
  final HabitIcon icon;
  final HabitSchedule schedule;
  final List<HabitReminder>? reminders;
  final bool isArchived;
}
