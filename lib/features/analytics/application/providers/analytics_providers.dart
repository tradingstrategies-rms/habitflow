import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/analytics_metrics_calculator.dart';
import '../../domain/services/family_productivity_score_calculator.dart';
import '../../../habits/application/providers/habit_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../domain/entities/analytics_metrics.dart';
import '../../domain/entities/daily_analytics_metric.dart';
import '../../domain/entities/analytics_trend.dart';
import '../../domain/entities/family_productivity_score.dart';

final analyticsCalculatorProvider = Provider<AnalyticsMetricsCalculator>((ref) {
  return const AnalyticsMetricsCalculator();
});

final familyProductivityCalculatorProvider = Provider<FamilyProductivityScoreCalculator>((ref) {
  final metricsCalculator = ref.watch(analyticsCalculatorProvider);
  return FamilyProductivityScoreCalculator(metricsCalculator);
});

/// A provider that calculates metrics for a specific habit and time range.
final habitAnalyticsProvider = Provider.family<AnalyticsMetrics, (String, DateTime, DateTime)>((ref, arg) {
  final habitId = arg.$1;
  final start = arg.$2;
  final end = arg.$3;
  
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  final calculator = ref.watch(analyticsCalculatorProvider);
  
  final completions = completionsAsync.value ?? [];
  
  return calculator.calculate(
    habitId: habitId,
    startDate: start,
    endDate: end,
    completions: completions,
  );
});

/// A provider that calculates daily metrics for a specific habit and time range.
final habitDailyAnalyticsProvider = Provider.family<List<DailyAnalyticsMetric>, (String, DateTime, DateTime)>((ref, arg) {
  final habitId = arg.$1;
  final start = arg.$2;
  final end = arg.$3;
  
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  final calculator = ref.watch(analyticsCalculatorProvider);
  
  final completions = completionsAsync.value ?? [];
  
  return calculator.calculateDailyMetrics(
    habitId: habitId,
    startDate: start,
    endDate: end,
    completions: completions,
  );
});

/// Provider for the currently selected period in Analytics
final analyticsPeriodProvider = StateProvider<Duration>((ref) => const Duration(days: 30));

/// Provider for the currently selected habit ID in Analytics
final selectedAnalyticsHabitIdProvider = StateProvider<String?>((ref) => null);

/// Provider for comparing two periods for a habit
final habitAnalyticsTrendProvider = Provider.family<AnalyticsTrend, (String, Duration)>((ref, arg) {
  final habitId = arg.$1;
  final duration = arg.$2;
  
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(duration);
  
  // Baseline is the previous period of same duration
  final baselineEnd = start.subtract(const Duration(days: 1));
  final baselineStart = baselineEnd.subtract(duration);
  
  final recent = ref.watch(habitAnalyticsProvider((habitId, start, end)));
  final baseline = ref.watch(habitAnalyticsProvider((habitId, baselineStart, baselineEnd)));
  
  final calculator = ref.watch(analyticsCalculatorProvider);
  return calculator.compare(baseline: baseline, recent: recent);
});

/// Provider for Family Productivity Score for a specific duration
final familyProductivityScoreProvider = Provider.family<AsyncValue<FamilyProductivityScore>, Duration>((ref, duration) {
  final familyState = ref.watch(familyProvider);
  final allHabitsAsync = ref.watch(habitsStreamProvider);
  final sharedHabitsAsync = ref.watch(sharedHabitsProvider);
  final completionsAsync = ref.watch(allHabitCompletionsProvider);
  
  if (allHabitsAsync.isLoading || sharedHabitsAsync.isLoading || completionsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final allHabits = allHabitsAsync.value ?? [];
  final sharedHabits = sharedHabitsAsync.value ?? [];
  final completions = completionsAsync.value ?? [];
  
  final calculator = ref.watch(familyProductivityCalculatorProvider);
  
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(duration);
  
  final familyId = familyState.circle?.id ?? 'none';
  
  // Calculate baseline for trend (previous period of same length)
  final baselineEnd = start.subtract(const Duration(days: 1));
  final baselineStart = baselineEnd.subtract(duration);
  
  final baseline = calculator.calculate(
    familyId: familyId,
    profiles: familyState.profiles,
    allHabits: allHabits,
    sharedHabits: sharedHabits,
    allCompletions: completions,
    startDate: baselineStart,
    endDate: baselineEnd,
  );

  final score = calculator.calculate(
    familyId: familyId,
    profiles: familyState.profiles,
    allHabits: allHabits,
    sharedHabits: sharedHabits,
    allCompletions: completions,
    startDate: start,
    endDate: end,
    baselineScore: baseline,
  );

  return AsyncValue.data(score);
});
