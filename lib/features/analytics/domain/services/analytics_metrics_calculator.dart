import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';

import '../entities/analytics_metrics.dart';

/// Calculates analytics from completion events without depending on presentation
/// or state-management layers.
class AnalyticsMetricsCalculator {
  const AnalyticsMetricsCalculator();

  AnalyticsMetrics calculate({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
    required Iterable<HabitCompletion> completions,
  }) {
    final start = analyticsDay(startDate);
    final end = analyticsDay(endDate);
    final days = end.difference(start).inDays + 1;
    final bounded = completions
        .where((completion) => completion.habitId == habitId)
        .where((completion) => completion.completed)
        .map((completion) => analyticsDay(completion.completionDate))
        .where((date) => !date.isBefore(start) && !date.isAfter(end))
        .toList()
      ..sort();

    final uniqueDays = bounded.toSet().toList()..sort();
    final longestStreak = _longestConsecutiveRun(uniqueDays);
    final gaps = <int>[];
    for (var i = 1; i < uniqueDays.length; i++) {
      gaps.add(uniqueDays[i].difference(uniqueDays[i - 1]).inDays);
    }

    return AnalyticsMetrics(
      habitId: habitId,
      startDate: start,
      endDate: end,
      completedCount: bounded.length,
      activeDays: uniqueDays.length,
      activityRate: days <= 0 ? 0 : uniqueDays.length / days,
      longestStreak: longestStreak,
      averageGapDays: gaps.isEmpty
          ? 0
          : gaps.reduce((a, b) => a + b) / gaps.length,
    );
  }

  AnalyticsTrend compare({
    required AnalyticsMetrics baseline,
    required AnalyticsMetrics recent,
    double stableThreshold = 0.05,
  }) {
    final delta = recent.activityRate - baseline.activityRate;
    final direction = delta > stableThreshold
        ? AnalyticsTrendDirection.improving
        : delta < -stableThreshold
            ? AnalyticsTrendDirection.declining
            : AnalyticsTrendDirection.stable;

    return AnalyticsTrend(
      direction: direction,
      recentRate: recent.activityRate,
      baselineRate: baseline.activityRate,
      delta: delta,
    );
  }

  int _longestConsecutiveRun(List<DateTime> dates) {
    if (dates.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}
