import 'habit_id.dart';
import 'habit_frequency.dart';
import 'habit_category.dart';
import 'habit_difficulty.dart';
import 'habit_color.dart';
import 'habit_icon.dart';
import 'habit_schedule.dart';
import 'habit_reminder.dart';

/// [Habit] represents a habit entity.
class Habit {
  const Habit({
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
    this.isArchived = false,
  });

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
