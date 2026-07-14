import '../../repositories/completion_repository.dart';
import '../../models/habit_id.dart';
import '../../models/completion/streak_calculator.dart';

class GetCurrentStreak {
  GetCurrentStreak(this._repository);
  final CompletionRepository _repository;

  Future<int> call(HabitId habitId) async {
    final history = await _repository.getCompletionHistory(habitId);
    return StreakCalculator.calculateCurrentStreak(history, DateTime.now());
  }
}
