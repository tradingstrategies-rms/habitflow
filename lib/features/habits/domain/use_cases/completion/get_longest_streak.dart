import '../../repositories/completion_repository.dart';
import '../../models/habit_id.dart';

class GetLongestStreak {
  GetLongestStreak(this._repository);
  final CompletionRepository _repository;

  Future<int> call(HabitId habitId) async {
    // For now, return longest streak from summary
    final summary = await _repository.getCompletionSummary(habitId);
    return summary.longestStreak;
  }
}
