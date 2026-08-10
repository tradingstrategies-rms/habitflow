import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/progress/models/progress_summary.dart';
import '../../../../core/progress/services/progress_aggregator.dart';
import '../../../../core/progress/services/progress_calculator.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../data/datasources/goal_local_datasource.dart';
import '../../data/repositories/goal_repository_impl.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../../../core/achievements/providers/achievement_providers.dart';
import '../controllers/goal_controller.dart';
import '../controllers/goal_creation_controller.dart';
import '../controllers/goal_edit_controller.dart';
import '../services/goal_completion_service.dart';
import '../services/goal_completion_watcher.dart';
import '../state/goal_state.dart';
import '../state/goal_creation_state.dart';
import '../state/goal_edit_state.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import '../../../habits/domain/entities/habit_completion.dart';

import '../../../rewards/presentation/providers/rewards_controller_provider.dart';

import 'package:habitflow/features/challenges/presentation/providers/challenges_controller_provider.dart';

/// Provider for [GoalLocalDataSource].
final goalLocalDataSourceProvider = Provider<GoalLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GoalLocalDataSource(prefs);
});

/// Provider for [GoalRepository].
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final dataSource = ref.watch(goalLocalDataSourceProvider);
  return GoalRepositoryImpl(dataSource);
});

/// Provider for [GoalController] and its state.
final goalControllerProvider = StateNotifierProvider<GoalController, GoalState>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalController(repository);
});

/// Provider for the full list of goals.
final goalsListProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalControllerProvider).goals;
});

/// Provider for active goals.
final activeGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalControllerProvider).activeGoals;
});

/// Provider for archived goals.
final archivedGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalControllerProvider).archivedGoals;
});

/// Provider for completed goals.
final completedGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalControllerProvider).completedGoals;
});

/// Provider for the currently selected goal.
final selectedGoalProvider = Provider<Goal?>((ref) {
  return ref.watch(goalControllerProvider).selectedGoal;
});

/// Provider for a specific goal by its ID.
final goalByIdProvider = Provider.family<Goal?, String>((ref, id) {
  final goals = ref.watch(goalsListProvider);
  return goals.cast<Goal?>().firstWhere((g) => g?.id == id, orElse: () => null);
});

/// Providers for Progress Engine components.
final progressCalculatorProvider = Provider<ProgressCalculator>((ref) {
  return ProgressCalculator();
});

final progressAggregatorProvider = Provider<ProgressAggregator>((ref) {
  final calculator = ref.watch(progressCalculatorProvider);
  return ProgressAggregator(calculator);
});

/// Provider for [ProgressSummary] of a specific goal.
final goalProgressProvider = FutureProvider.family<ProgressSummary, Goal>((ref, goal) async {
  final aggregator = ref.watch(progressAggregatorProvider);
  
  // Watch all completions to trigger refresh when a habit is completed.
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  
  final completions = completionsAsync.value ?? [];
  
  return aggregator.aggregate(goal, completions);
});

/// Provider for [GoalCompletionWatcher].
final goalCompletionWatcherProvider = Provider<GoalCompletionWatcher>((ref) {
  final watcher = GoalCompletionWatcher(ref);
  // React to habit completions to detect goal progress
  ref.listen<AsyncValue<List<HabitCompletion>>>(
    allHabitCompletionsProvider,
    (previous, next) {
      final completions = next.value;
      if (completions != null) {
        watcher.checkAllGoals(completions);
      }
    },
  );
  return watcher;
});

/// Provider for [GoalCreationController].
final goalCreationControllerProvider = StateNotifierProvider.autoDispose<GoalCreationController, GoalCreationState>((ref) {
  final goalController = ref.watch(goalControllerProvider.notifier);
  return GoalCreationController(goalController);
});

/// Provider for [GoalEditController].
final goalEditControllerProvider = StateNotifierProvider.family.autoDispose<GoalEditController, GoalEditState, Goal>((ref, goal) {
  final goalController = ref.watch(goalControllerProvider.notifier);
  return GoalEditController(goalController, goal);
});

/// Provider for [GoalCompletionService].
final goalCompletionServiceProvider = Provider<GoalCompletionService>((ref) {
  final goalController = ref.watch(goalControllerProvider.notifier);
  final eventBus = ref.watch(achievementEventBusProvider);
  final rewardsController = ref.watch(rewardsControllerProvider);
  final challengesController = ref.watch(challengesControllerProvider);
  return GoalCompletionService(goalController, eventBus, rewardsController, challengesController);
});
