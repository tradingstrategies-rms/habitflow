import '../models/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabit {
  CreateHabit(this._repository);
  final HabitRepository _repository;

  Future<void> call(Habit habit) async {
    // Basic validation could be done here
    return _repository.createHabit(habit);
  }
}
