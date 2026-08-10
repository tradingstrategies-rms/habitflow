import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/habits/domain/repositories/habit_completion_repository.dart';
import 'package:habitflow/features/habits/domain/repositories/habit_repository.dart';
import 'package:habitflow/features/habits/domain/repositories/reminder_repository.dart';
import 'package:habitflow/features/habits/infrastructure/datasources/local_habit_datasource.dart';
import 'package:habitflow/features/habits/infrastructure/repositories/local_habit_completion_repository.dart';
import 'package:habitflow/features/habits/infrastructure/repositories/local_habit_repository.dart';
import 'package:habitflow/features/habits/infrastructure/repositories/local_reminder_repository.dart';

final habitDataSourceProvider = Provider<LocalHabitDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalHabitDataSource(prefs);
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final dataSource = ref.watch(habitDataSourceProvider);
  final repository = LocalHabitRepository(dataSource);
  ref.onDispose(() => repository.dispose());
  return repository;
});

final habitCompletionRepositoryProvider = Provider<HabitCompletionRepository>((ref) {
  final dataSource = ref.watch(habitDataSourceProvider);
  final repository = LocalHabitCompletionRepository(dataSource);
  ref.onDispose(() => repository.dispose());
  return repository;
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalReminderRepository(prefs);
});
