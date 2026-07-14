import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/features/habits/domain/models/habit.dart';
import 'package:habitflow/features/habits/domain/repositories/habit_repository.dart';
import 'package:habitflow/features/habits/domain/repositories/completion_repository.dart';
import 'package:habitflow/features/habits/data/local_habit_data_source.dart';
import 'package:habitflow/features/habits/data/habit_repository_impl.dart';
import 'package:habitflow/features/habits/data/completion/completion_repository_impl.dart';

final localHabitDataSourceProvider = Provider<LocalHabitDataSource>((ref) {
  return LocalHabitDataSource(ref.watch(storageProvider));
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(localHabitDataSourceProvider));
});

final completionRepositoryProvider = Provider<CompletionRepository>((ref) {
  return CompletionRepositoryImpl(ref.watch(storageProvider));
});

final allHabitsProvider = StateNotifierProvider<AllHabitsNotifier, AsyncValue<List<Habit>>>((ref) {
  return AllHabitsNotifier(ref.watch(habitRepositoryProvider));
});

class AllHabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  AllHabitsNotifier(this._repository) : super(const AsyncLoading()) {
    refresh();
  }
  
  final HabitRepository _repository;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await _repository.getAllHabits().first);
  }
}
