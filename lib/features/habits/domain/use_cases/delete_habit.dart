import '../models/habit_id.dart';
import '../repositories/habit_repository.dart';

class DeleteHabit {
  DeleteHabit(this._repository);
  final HabitRepository _repository;

  Future<void> call(HabitId habitId) async {
    return _repository.deleteHabit(habitId);
  }
}
