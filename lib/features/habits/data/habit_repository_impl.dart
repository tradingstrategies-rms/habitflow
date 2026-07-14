import '../domain/models/habit.dart';
import '../domain/models/habit_id.dart';
import '../domain/repositories/habit_repository.dart';
import 'local_habit_data_source.dart';
import 'habit_mapper.dart';

/// [HabitRepositoryImpl] implements [HabitRepository] using local persistence.
class HabitRepositoryImpl implements HabitRepository {
  HabitRepositoryImpl(this._dataSource);

  final LocalHabitDataSource _dataSource;

  @override
  Future<void> createHabit(Habit habit) async {
    final habits = await _dataSource.getAllHabits();
    habits.add(HabitMapper.fromDomain(habit));
    await _dataSource.saveAllHabits(habits);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final habits = await _dataSource.getAllHabits();
    final index = habits.indexWhere((h) => h.id.value == habit.id.value);
    if (index != -1) {
      habits[index] = HabitMapper.fromDomain(habit);
      await _dataSource.saveAllHabits(habits);
    }
  }

  @override
  Future<void> deleteHabit(HabitId habitId) async {
    final habits = await _dataSource.getAllHabits();
    habits.removeWhere((h) => h.id.value == habitId.value);
    await _dataSource.saveAllHabits(habits);
  }

  @override
  Future<Habit?> getHabit(HabitId habitId) async {
    final habits = await _dataSource.getAllHabits();
    final model = habits.firstWhere((h) => h.id.value == habitId.value, orElse: () => throw Exception("Habit not found"));
    return HabitMapper.toDomain(model);
  }

  @override
  Stream<List<Habit>> getAllHabits() async* {
    final habits = await _dataSource.getAllHabits();
    yield habits.map((m) => HabitMapper.toDomain(m)).toList();
  }
}
