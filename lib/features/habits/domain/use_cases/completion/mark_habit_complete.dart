import '../../repositories/completion_repository.dart';
import '../../models/habit_id.dart';

class MarkHabitComplete {
  MarkHabitComplete(this._repository);
  final CompletionRepository _repository;

  Future<void> call(HabitId habitId, DateTime date) async {
    return _repository.markComplete(habitId, date);
  }
}
