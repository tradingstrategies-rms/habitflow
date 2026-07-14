import '../models/habit.dart';
import '../models/habit_id.dart';
import '../repositories/habit_repository.dart';

class GetHabit {
  GetHabit(this._repository);
  final HabitRepository _repository;

  Future<Habit?> call(HabitId habitId) async {
    return _repository.getHabit(habitId);
  }
}
