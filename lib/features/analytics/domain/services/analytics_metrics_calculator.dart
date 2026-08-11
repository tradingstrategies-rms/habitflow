import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import '../entities/analytics_metrics.dart';
import '../entities/analytics_trend.dart';
import '../entities/daily_analytics_metric.dart';

/// Calculates analytics from completion events without depending on presentation
/// or state-management layers.
class AnalyticsMetricsCalculator {
  const AnalyticsMetricsCalculator();

  /// Normalizes a [DateTime] to the start of its calendar day.
  DateTime analyticsDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculates [AnalyticsMetrics] for a specific habit within a date window.
  AnalyticsMetrics calculate({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
    required Iterable<HabitCompletion> completions,
  }) {
    final start = analyticsDay(startDate);
    final end = analyticsDay(endDate);
    final daysInWindow = end.difference(start).inDays + 1;

    // Filter and normalize completions
    final habitCompletions = completions
        .where((c) => c.habitId == habitId && c.completed)
        .where((c) {
          final date = analyticsDay(c.completionDate);
          return !date.isBefore(start) && !date.isAfter(end);
        })
        .toList();

    final uniqueCompletionDays = habitCompletions
        .map((c) => analyticsDay(c.completionDate))
        .toSet()
        .toList()
      ..sort();

    final longestStreak = _calculateLongestStreak(uniqueCompletionDays);
    final averageGap = _calculateAverageGap(uniqueCompletionDays);

    return AnalyticsMetrics(
      habitId: habitId,
      startDate: start,
      endDate: end,
      completedCount: habitCompletions.length,
      activeDays: uniqueCompletionDays.length,
      activityRate: daysInWindow <= 0 ? 0.0 : uniqueCompletionDays.length / daysInWindow,
      longestStreak: longestStreak,
      averageGapDays: averageGap,
    );
  }

  /// Generates a list of [DailyAnalyticsMetric] for a date window.
  List<DailyAnalyticsMetric> calculateDailyMetrics({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
    required Iterable<HabitCompletion> completions,
  }) {
    final start = analyticsDay(startDate);
    final end = analyticsDay(endDate);
    final daysCount = end.difference(start).inDays + 1;

    final habitCompletions = completions
        .where((c) => c.habitId == habitId && c.completed)
        .toList();

    return List.generate(daysCount, (index) {
      final date = start.add(Duration(days: index));
      final dayCompletions = habitCompletions.where((c) {
        final cDate = analyticsDay(c.completionDate);
        return cDate.isAtSameMomentAs(date);
      }).toList();

      return DailyAnalyticsMetric(
        date: date,
        isActive: dayCompletions.isNotEmpty,
        completionCount: dayCompletions.length,
      );
    });
  }

  /// Compares two periods to determine a [AnalyticsTrend].
  AnalyticsTrend compare({
    required AnalyticsMetrics baseline,
    required AnalyticsMetrics recent,
    double stableThreshold = 0.05,
  }) {
    final delta = recent.activityRate - baseline.activityRate;
    
    AnalyticsTrendDirection direction;
    if (delta > stableThreshold) {
      direction = AnalyticsTrendDirection.improving;
    } else if (delta < -stableThreshold) {
      direction = AnalyticsTrendDirection.declining;
    } else {
      direction = AnalyticsTrendDirection.stable;
    }

    return AnalyticsTrend(
      direction: direction,
      recent: recent,
      baseline: baseline,
      delta: delta,
    );
  }

  int _calculateLongestStreak(List<DateTime> sortedDates) {
    if (sortedDates.isEmpty) return 0;
    
    int longest = 1;
    int current = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      if (sortedDates[i].difference(sortedDates[i - 1]).inDays == 1) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }
    
    return longest;
  }

  double _calculateAverageGap(List<DateTime> sortedDates) {
    if (sortedDates.length < 2) return 0.0;
    
    int totalGap = 0;
    for (int i = 1; i < sortedDates.length; i++) {
      totalGap += sortedDates[i].difference(sortedDates[i - 1]).inDays;
    }
    
    return totalGap / (sortedDates.length - 1);
  }
}
