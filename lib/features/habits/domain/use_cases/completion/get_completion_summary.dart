import '../../repositories/completion_repository.dart';
import '../../models/habit_id.dart';
import '../../models/completion/completion_summary.dart';

class GetCompletionSummary {
  GetCompletionSummary(this._repository);
  final CompletionRepository _repository;

  Future<CompletionSummary> call(HabitId habitId) async {
    return _repository.getCompletionSummary(habitId);
  }
}
