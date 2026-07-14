import '../models/habit.dart';
import '../repositories/habit_repository.dart';

class GetAllHabits {
  GetAllHabits(this._repository);
  final HabitRepository _repository;

  Stream<List<Habit>> call() {
    return _repository.getAllHabits();
  }
}
