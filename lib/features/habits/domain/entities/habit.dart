import '../value_objects/habit_category.dart';
import '../value_objects/habit_color.dart';
import '../value_objects/habit_frequency.dart';
import '../value_objects/habit_icon.dart';
import '../value_objects/habit_priority.dart';

class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final HabitCategory category;
  final HabitIcon icon;
  final HabitColor color;
  final HabitPriority priority;
  final HabitFrequency frequency;
  final double targetValue;
  final double currentValue;
  final String unit;
  final bool isArchived;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.priority,
    required this.frequency,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.unit,
    this.isArchived = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}
