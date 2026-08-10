import '../../domain/entities/habit.dart';
import '../../domain/value_objects/habit_category.dart';
import '../../domain/value_objects/habit_color.dart';
import '../../domain/value_objects/habit_frequency.dart';
import '../../domain/value_objects/habit_icon.dart';
import '../../domain/value_objects/habit_priority.dart';

class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final String icon;
  final String color;
  final String priority;
  final String frequency;
  final double targetValue;
  final double currentValue;
  final String unit;
  final bool isArchived;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const HabitModel({
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
    required this.currentValue,
    required this.unit,
    required this.isArchived,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      priority: json['priority'] as String,
      frequency: json['frequency'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      unit: json['unit'] as String,
      isArchived: json['isArchived'] as bool,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'priority': priority,
      'frequency': frequency,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'isArchived': isArchived,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory HabitModel.fromEntity(Habit entity) {
    return HabitModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      category: entity.category.name,
      icon: entity.icon.name,
      color: entity.color.name,
      priority: entity.priority.name,
      frequency: entity.frequency.name,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      unit: entity.unit,
      isArchived: entity.isArchived,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  Habit toEntity() {
    return Habit(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: HabitCategory.values.firstWhere((e) => e.name == category),
      icon: HabitIcon.values.firstWhere((e) => e.name == icon),
      color: HabitColor.values.firstWhere((e) => e.name == color),
      priority: HabitPriority.values.firstWhere((e) => e.name == priority),
      frequency: HabitFrequency.values.firstWhere((e) => e.name == frequency),
      targetValue: targetValue,
      currentValue: currentValue,
      unit: unit,
      isArchived: isArchived,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
