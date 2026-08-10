import '../entities/habit_completion.dart';

abstract class HabitCompletionRepository {
  Future<void> saveCompletion(HabitCompletion completion);
  Future<void> removeCompletion(String habitId, DateTime date, {String? profileId});
  Future<HabitCompletion?> getTodayCompletion(String habitId, {String? profileId});
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId, {String? profileId});
  Future<List<HabitCompletion>> getAllCompletions();
  Stream<List<HabitCompletion>> watchCompletions(String habitId, {String? profileId});
  Stream<List<HabitCompletion>> watchAllCompletions();
}
