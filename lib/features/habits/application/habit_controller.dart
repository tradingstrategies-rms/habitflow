import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/habit.dart';
import '../domain/use_cases/create_habit.dart';
import '../domain/use_cases/update_habit.dart';
import '../domain/use_cases/delete_habit.dart';
import '../domain/use_cases/get_habit.dart';
import '../data/habit_providers.dart';

// Use cases providers
final createHabitProvider = Provider((ref) => CreateHabit(ref.read(habitRepositoryProvider)));
final updateHabitProvider = Provider((ref) => UpdateHabit(ref.read(habitRepositoryProvider)));
final deleteHabitProvider = Provider((ref) => DeleteHabit(ref.read(habitRepositoryProvider)));
final getHabitProvider = Provider((ref) => GetHabit(ref.read(habitRepositoryProvider)));

class HabitController extends StateNotifier<AsyncValue<void>> {
  HabitController({
    required this.createHabit,
    required this.updateHabit,
  }) : super(const AsyncData(null));

  final CreateHabit createHabit;
  final UpdateHabit updateHabit;

  Future<void> saveHabit(Habit habit, bool isEditing) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (isEditing) {
        await updateHabit(habit);
      } else {
        await createHabit(habit);
      }
    });
  }
}

final habitControllerProvider = StateNotifierProvider<HabitController, AsyncValue<void>>((ref) {
  return HabitController(
    createHabit: ref.read(createHabitProvider),
    updateHabit: ref.read(updateHabitProvider),
  );
});
