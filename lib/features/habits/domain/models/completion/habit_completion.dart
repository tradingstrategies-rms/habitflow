import '../../models/habit_id.dart';

/// [HabitCompletion] represents a single completion event for a habit.
class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
  });

  final String id;
  final HabitId habitId;
  final DateTime date;
}
