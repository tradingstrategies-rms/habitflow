import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import '../../application/providers/goal_providers.dart';
import '../models/goal_analytics_summary.dart';
import '../models/goal_habit_contribution.dart';
import '../services/goal_analytics_service.dart';

/// Provider for the [GoalAnalyticsService].
final goalAnalyticsServiceProvider = Provider<GoalAnalyticsService>((ref) {
  return GoalAnalyticsService();
});

/// Family provider that exposes analytics for a specific goal.
final goalAnalyticsProvider = FutureProvider.family<GoalAnalyticsSummary, String>((ref, goalId) async {
  final goal = ref.watch(goalByIdProvider(goalId));
  if (goal == null) return GoalAnalyticsSummary.empty(goalId);

  final service = ref.watch(goalAnalyticsServiceProvider);
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  final habitsAsync = ref.watch(activeHabitsProvider);

  // Wait for data
  final completions = completionsAsync.value ?? [];
  final habits = habitsAsync.value ?? [];

  return service.analyze(
    goal: goal,
    completions: completions,
    habits: habits,
  );
});

/// Family provider that exposes habit contributions for a specific goal.
final goalHabitContributionProvider = FutureProvider.family<List<GoalHabitContribution>, String>((ref, goalId) async {
  final goal = ref.watch(goalByIdProvider(goalId));
  if (goal == null) return [];

  final service = ref.watch(goalAnalyticsServiceProvider);
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  final habitsAsync = ref.watch(activeHabitsProvider);

  final completions = completionsAsync.value ?? [];
  final habits = habitsAsync.value ?? [];

  // Filter relevant completions
  final relevantCompletions = completions.where((c) {
    final isLinked = goal.habitIds.contains(c.habitId);
    final isAfterStart = !c.completionDate.isBefore(goal.startDate);
    final isBeforeEnd = !c.completionDate.isAfter(goal.endDate);
    return isLinked && isAfterStart && isBeforeEnd && c.completed;
  }).toList();

  return service.calculateContributions(
    goal: goal,
    completions: relevantCompletions,
    habits: habits,
  );
});

/// Family provider that exposes a textual insight for a specific goal.
final goalInsightProvider = FutureProvider.family<String, String>((ref, goalId) async {
  final goal = ref.watch(goalByIdProvider(goalId));
  if (goal == null) return '';

  final service = ref.watch(goalAnalyticsServiceProvider);
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  final completions = completionsAsync.value ?? [];

  final relevantCompletions = completions.where((c) {
    final isLinked = goal.habitIds.contains(c.habitId);
    final isAfterStart = !c.completionDate.isBefore(goal.startDate);
    final isBeforeEnd = !c.completionDate.isAfter(goal.endDate);
    return isLinked && isAfterStart && isBeforeEnd && c.completed;
  }).toList();

  return service.generateInsight(completions: relevantCompletions);
});
