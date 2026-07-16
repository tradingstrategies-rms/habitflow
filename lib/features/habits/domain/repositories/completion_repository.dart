import '../models/habit_id.dart';
import '../models/completion/habit_completion.dart';
import '../models/completion/completion_summary.dart';

abstract class CompletionRepository {
  Future<void> markComplete(HabitId habitId, DateTime date);
  Future<void> undoCompletion(HabitId habitId, DateTime date);
  Future<List<HabitCompletion>> getCompletionHistory(HabitId habitId);
  Future<List<HabitCompletion>> getAllCompletions();
  Future<CompletionSummary> getCompletionSummary(HabitId habitId);
}
