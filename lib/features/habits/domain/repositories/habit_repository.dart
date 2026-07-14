import '../models/habit.dart';
import '../models/habit_id.dart';

/// [HabitRepository] defines the domain-level interface for habit management.
abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(HabitId habitId);
  Future<Habit?> getHabit(HabitId habitId);
  Stream<List<Habit>> getAllHabits();
}
