import '../entities/habit.dart';

abstract class HabitRepository {
  Future<void> createHabit(Habit habit);
  
  Future<void> updateHabit(Habit habit);
  
  Future<void> deleteHabit(String id);
  
  Future<void> archiveHabit(String id);
  
  Future<void> restoreHabit(String id);
  
  Future<Habit?> getHabitById(String id);
  
  Future<List<Habit>> getAllHabits();
  
  Future<List<Habit>> getActiveHabits();
  
  Future<List<Habit>> getArchivedHabits();
  
  Future<List<Habit>> getTodayHabits();
  
  Stream<List<Habit>> watchHabits();
}
