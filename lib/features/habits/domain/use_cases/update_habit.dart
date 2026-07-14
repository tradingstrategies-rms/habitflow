import '../models/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit {
  UpdateHabit(this._repository);
  final HabitRepository _repository;

  Future<void> call(Habit habit) async {
    return _repository.updateHabit(habit);
  }
}
