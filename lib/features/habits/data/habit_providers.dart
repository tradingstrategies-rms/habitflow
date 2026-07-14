import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models/habit.dart';
import '../domain/repositories/habit_repository.dart';
import 'local_habit_data_source.dart';
import 'habit_repository_impl.dart';

final localHabitDataSourceProvider = Provider<LocalHabitDataSource>((ref) {
  return LocalHabitDataSource(ref.watch(storageProvider));
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepositoryImpl(ref.watch(localHabitDataSourceProvider));
});

final allHabitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).getAllHabits();
});
