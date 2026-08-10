import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/controllers/habit_controller.dart';
import 'package:habitflow/features/habits/application/providers/habit_repository_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';

import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import 'package:habitflow/features/habits/application/services/habit_streak_service.dart';

import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';

import 'package:habitflow/features/rewards/presentation/providers/rewards_controller_provider.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenges_controller_provider.dart';

final habitControllerProvider = Provider<HabitController>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  final completionRepository = ref.watch(habitCompletionRepositoryProvider);
  final familyRepository = ref.watch(familyRepositoryProvider);
  final streakService = ref.watch(habitStreakServiceProvider);
  final rewardsController = ref.watch(rewardsControllerProvider);
  final challengesController = ref.watch(challengesControllerProvider);
  
  return HabitController(
    repository, 
    completionRepository, 
    familyRepository, 
    streakService, 
    rewardsController,
    challengesController,
  );
});

final habitStreakServiceProvider = Provider<HabitStreakService>((ref) {
  return HabitStreakService();
});

final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.watchHabits();
});

final activeHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  final habitsAsync = ref.watch(habitsStreamProvider);
  final activeProfile = ref.watch(activeProfileProvider);
  final sharedHabitsAsync = ref.watch(sharedHabitsProvider);

  return habitsAsync.whenData((habits) {
    final active = habits.where((h) => !h.isArchived && h.isActive).toList();
    if (activeProfile == null) return active;

    final sharedHabits = sharedHabitsAsync.value ?? [];
    
    return active.where((h) {
      // 1. Own habit
      if (h.userId == activeProfile.id) return true;
      
      // 2. Shared habit where member is assigned
      SharedHabit? sh;
      try {
        sh = sharedHabits.firstWhere((s) => s.habitId == h.id);
      } catch (_) {}

      if (sh != null && sh.assignedMemberIds.contains(activeProfile.id)) return true;
      
      return false;
    }).toList();
  });
});

final archivedHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(habitsStreamProvider).whenData(
        (habits) => habits.where((h) => h.isArchived).toList(),
      );
});

final todaysHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  return ref.watch(activeHabitsProvider).whenData(
        (habits) => habits, // TODO: Filter by frequency
      );
});

final todayCompletionProvider = FutureProvider.family<HabitCompletion?, String>((ref, habitId) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  final activeProfile = ref.watch(activeProfileProvider);
  return repository.getTodayCompletion(habitId, profileId: activeProfile?.id);
});

final anyTodayCompletionProvider = FutureProvider.family<HabitCompletion?, String>((ref, habitId) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getTodayCompletion(habitId);
});

final profileTodayCompletionProvider = FutureProvider.family<HabitCompletion?, (String, String)>((ref, arg) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getTodayCompletion(arg.$1, profileId: arg.$2);
});

final habitCompletionsProvider = StreamProvider.family<List<HabitCompletion>, String>((ref, habitId) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.watchCompletions(habitId);
});

final allHabitCompletionsProvider = StreamProvider<List<HabitCompletion>>((ref) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.watchAllCompletions();
});

final streakProvider = Provider.family<AsyncValue<int>, String>((ref, habitId) {
  final completionsAsync = ref.watch(habitCompletionsProvider(habitId));
  final service = ref.watch(habitStreakServiceProvider);
  
  return completionsAsync.whenData((list) => service.calculateCurrentStreak(list));
});

final bestStreakProvider = Provider.family<AsyncValue<int>, String>((ref, habitId) {
  final completionsAsync = ref.watch(habitCompletionsProvider(habitId));
  final service = ref.watch(habitStreakServiceProvider);
  
  return completionsAsync.whenData((list) => service.calculateBestStreak(list));
});

final completionPercentageProvider = Provider.family<AsyncValue<double>, String>((ref, habitId) {
  final completionsAsync = ref.watch(habitCompletionsProvider(habitId));
  final service = ref.watch(habitStreakServiceProvider);
  
  return completionsAsync.whenData((list) => service.calculateCompletionPercentage(list, 30));
});

final habitByIdProvider = FutureProvider.family<Habit?, String>((ref, id) async {
  final habits = await ref.watch(habitsStreamProvider.future);
  return habits.firstWhere((h) => h.id == id, orElse: () => throw Exception('Habit not found'));
});
