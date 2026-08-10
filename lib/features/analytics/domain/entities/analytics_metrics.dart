/// Immutable, presentation-agnostic metrics for a habit over an analytics window.
class AnalyticsMetrics {
  const AnalyticsMetrics({
    required this.habitId,
    required this.startDate,
    required this.endDate,
    required this.completedCount,
    required this.activeDays,
    required this.activityRate,
    required this.longestStreak,
    required this.averageGapDays,
  });

  final String habitId;
  final DateTime startDate;
  final DateTime endDate;
  final int completedCount;
  final int activeDays;
  final double activityRate;
  final int longestStreak;
  final double averageGapDays;
}

/// One day's observed completion activity.
class DailyAnalyticsMetric {
  const DailyAnalyticsMetric({
    required this.date,
    required this.completionCount,
  });

  final DateTime date;
  final int completionCount;
}

/// Direction of change between two comparable analytics windows.
enum AnalyticsTrendDirection {
  improving,
  declining,
  stable,
}

class AnalyticsTrend {
  const AnalyticsTrend({
    required this.direction,
    required this.recentRate,
    required this.baselineRate,
    required this.delta,
  });

  final AnalyticsTrendDirection direction;
  final double recentRate;
  final double baselineRate;
  final double delta;
}

DateTime analyticsDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);
