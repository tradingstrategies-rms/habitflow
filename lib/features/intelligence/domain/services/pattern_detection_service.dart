import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:uuid/uuid.dart';
import '../entities/habit_pattern.dart';

/// Service responsible for detecting behavioral patterns in habit completion history.
class PatternDetectionService {
  final _uuid = const Uuid();

  // Time-of-day boundaries
  static const int morningStart = 5;
  static const int morningEnd = 11;
  static const int afternoonStart = 12;
  static const int afternoonEnd = 16;
  static const int eveningStart = 17;
  static const int eveningEnd = 21;
  static const int nightStart = 22;
  static const int nightEnd = 4;

  // Thresholds
  static const int minObservationsForConfidence = 5;
  static const int trendWindowRecentDays = 7;
  static const int trendWindowHistoricalDays = 30;
  static const double trendChangeThreshold = 0.2; // 20% change
  static const double fadingTrendThreshold = -0.15; // 15% decline for fading
  static const int longGapThresholdDays = 3;
  static const int fastRecoveryMaxDays = 1;

  List<HabitPattern> detectPatterns({
    required Habit habit,
    required List<HabitCompletion> history,
    AnalyticsMetrics? metrics,
    AnalyticsTrend? trend,
  }) {
    if (history.isEmpty) return [];

    final successfulCompletions = history.where((c) => c.completed).toList()
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    if (successfulCompletions.isEmpty) return [];

    final patterns = <HabitPattern>[];

    // 1. Morning vs Evening Strength
    final timePattern = _detectTimeOfDayPattern(habit.id, successfulCompletions);
    if (timePattern != null) patterns.add(timePattern);

    // 2. Weekday vs Weekend
    final weekPartPattern = _detectWeekdayWeekendPattern(habit.id, successfulCompletions);
    if (weekPartPattern != null) patterns.add(weekPartPattern);

    // 3 & 4. Trends (Prefer using passed trend if available)
    if (trend != null) {
      final trendPattern = _detectTrendFromAnalytics(habit.id, trend, history.length);
      if (trendPattern != null) patterns.add(trendPattern);
    } else {
      final trendPattern = _detectTrendPattern(habit.id, successfulCompletions);
      if (trendPattern != null) patterns.add(trendPattern);
    }

    // 5 & 6. Consistency
    final consistencyPattern = _detectConsistencyPattern(habit.id, successfulCompletions, metrics);
    if (consistencyPattern != null) patterns.add(consistencyPattern);

    // 7. Longest Inactive Gap
    final gapPattern = _detectGapPattern(habit.id, successfulCompletions);
    if (gapPattern != null) patterns.add(gapPattern);

    // 8 & 9. Recovery
    final recoveryPattern = _detectRecoveryPattern(habit.id, successfulCompletions);
    if (recoveryPattern != null) patterns.add(recoveryPattern);

    // 11 & 12. Best/Weakest Days
    final weekdayPatterns = _detectWeekdayPerformancePatterns(habit.id, successfulCompletions);
    patterns.addAll(weekdayPatterns);

    return patterns;
  }

  HabitPattern? _detectTrendFromAnalytics(String habitId, AnalyticsTrend trend, int historyLength) {
    if (trend.direction == AnalyticsTrendDirection.improving) {
      return _createPattern(
        habitId,
        PatternType.improvingTrend,
        PatternSeverity.high,
        _calculateConfidence(historyLength),
        'pattern_improving_trend',
        {'improvement': trend.delta},
      );
    } else if (trend.direction == AnalyticsTrendDirection.declining) {
      return _createPattern(
        habitId,
        PatternType.decliningTrend,
        PatternSeverity.high,
        _calculateConfidence(historyLength),
        'pattern_declining_trend',
        {'decline': trend.delta.abs()},
      );
    }
    return null;
  }

  HabitPattern? _detectTimeOfDayPattern(String habitId, List<HabitCompletion> history) {
    if (history.length < minObservationsForConfidence) return null;

    int morning = 0;
    int evening = 0;

    for (final completion in history) {
      final hour = completion.completedAt.hour;
      if (hour >= morningStart && hour <= morningEnd) {
        morning++;
      } else if (hour >= eveningStart && hour <= eveningEnd) {
        evening++;
      }
    }

    final total = history.length;
    final morningRate = morning / total;
    final eveningRate = evening / total;

    if (morningRate > 0.6) {
      return _createPattern(
        habitId,
        PatternType.morningStrength,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_morning_strength',
        {'morning_rate': morningRate},
      );
    } else if (eveningRate > 0.6) {
      return _createPattern(
        habitId,
        PatternType.eveningStrength,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_evening_strength',
        {'evening_rate': eveningRate},
      );
    }

    return null;
  }

  HabitPattern? _detectWeekdayWeekendPattern(String habitId, List<HabitCompletion> history) {
    if (history.length < minObservationsForConfidence) return null;

    int weekdays = 0;
    int weekends = 0;
    int totalWeekdaysInHistory = 0;
    int totalWeekendsInHistory = 0;

    // We need to count actual occurrences of days in the history range to get a rate
    final first = history.first.completionDate;
    final last = history.last.completionDate;
    
    for (DateTime d = first; d.isBefore(last.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      if (d.weekday == DateTime.saturday || d.weekday == DateTime.sunday) {
        totalWeekendsInHistory++;
      } else {
        totalWeekdaysInHistory++;
      }
    }

    for (final completion in history) {
      if (completion.completionDate.weekday == DateTime.saturday || 
          completion.completionDate.weekday == DateTime.sunday) {
        weekends++;
      } else {
        weekdays++;
      }
    }

    final weekdayRate = totalWeekdaysInHistory > 0 ? weekdays / totalWeekdaysInHistory : 0.0;
    final weekendRate = totalWeekendsInHistory > 0 ? weekends / totalWeekendsInHistory : 0.0;

    if (weekdayRate > 0.8 && weekendRate < 0.4) {
      return _createPattern(
        habitId,
        PatternType.weekdayStrength,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_weekday_strength',
        {'weekday_rate': weekdayRate, 'weekend_rate': weekendRate},
      );
    } else if (weekendRate > 0.8 && weekdayRate < 0.4) {
      return _createPattern(
        habitId,
        PatternType.weekendWeakness, // Actually weekend strength but name indicates a weekend focus
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_weekend_focus',
        {'weekend_rate': weekendRate, 'weekday_rate': weekdayRate},
      );
    }

    return null;
  }

  HabitPattern? _detectTrendPattern(String habitId, List<HabitCompletion> history) {
    if (history.length < 10) return null;

    final now = DateTime.now();
    final recentCutoff = now.subtract(const Duration(days: trendWindowRecentDays));
    final historicalCutoff = now.subtract(const Duration(days: trendWindowHistoricalDays));

    final recentCompletions = history.where((c) => c.completionDate.isAfter(recentCutoff)).length;
    final historicalCompletions = history.where((c) => 
      c.completionDate.isAfter(historicalCutoff) && c.completionDate.isBefore(recentCutoff)).length;

    final recentRate = recentCompletions / trendWindowRecentDays;
    final historicalRate = historicalCompletions / (trendWindowHistoricalDays - trendWindowRecentDays);

    if (recentRate > historicalRate + trendChangeThreshold) {
      return _createPattern(
        habitId,
        PatternType.improvingTrend,
        PatternSeverity.high,
        _calculateConfidence(history.length),
        'pattern_improving_trend',
        {'improvement': recentRate - historicalRate},
      );
    } else if (recentRate < historicalRate - trendChangeThreshold) {
      return _createPattern(
        habitId,
        PatternType.decliningTrend,
        PatternSeverity.high,
        _calculateConfidence(history.length),
        'pattern_declining_trend',
        {'decline': historicalRate - recentRate},
      );
    }

    return null;
  }

  HabitPattern? _detectConsistencyPattern(String habitId, List<HabitCompletion> history, AnalyticsMetrics? metrics) {
    if (metrics != null) {
      if (metrics.activityRate > 0.9) {
        return _createPattern(
          habitId,
          PatternType.highConsistency,
          PatternSeverity.high,
          _calculateConfidence(history.length),
          'pattern_high_consistency',
          {'activity_rate': metrics.activityRate},
        );
      } else if (metrics.activityRate < 0.3 && history.length > 10) {
        return _createPattern(
          habitId,
          PatternType.lowConsistency,
          PatternSeverity.medium,
          _calculateConfidence(history.length),
          'pattern_low_consistency',
          {'activity_rate': metrics.activityRate},
        );
      }
    }

    if (history.length < 10) return null;

    final gaps = <int>[];
    for (int i = 1; i < history.length; i++) {
      gaps.add(history[i].completionDate.difference(history[i - 1].completionDate).inDays);
    }

    double avgGap = gaps.fold(0, (a, b) => a + b) / gaps.length;
    double variance = gaps.fold(0.0, (a, b) => a + (b - avgGap) * (b - avgGap)) / gaps.length;

    if (variance < 0.5 && avgGap < 1.5) {
      return _createPattern(
        habitId,
        PatternType.highConsistency,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_high_consistency',
        {'variance': variance},
      );
    } else if (variance > 4.0) {
      return _createPattern(
        habitId,
        PatternType.lowConsistency,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_low_consistency',
        {'variance': variance},
      );
    }

    return null;
  }

  HabitPattern? _detectGapPattern(String habitId, List<HabitCompletion> history) {
    int maxGap = 0;
    for (int i = 1; i < history.length; i++) {
      final gap = history[i].completionDate.difference(history[i - 1].completionDate).inDays;
      if (gap > maxGap) maxGap = gap;
    }

    if (maxGap >= longGapThresholdDays) {
      return _createPattern(
        habitId,
        PatternType.longInactiveGap,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_long_gap',
        {'max_gap': maxGap},
      );
    }
    return null;
  }

  HabitPattern? _detectRecoveryPattern(String habitId, List<HabitCompletion> history) {
    if (history.length < 5) return null;

    final gaps = <int>[];
    for (int i = 1; i < history.length; i++) {
      final gap = history[i].completionDate.difference(history[i - 1].completionDate).inDays;
      if (gap > 1) gaps.add(gap);
    }

    if (gaps.isEmpty) return null;

    double avgRecovery = gaps.fold(0, (a, b) => a + b) / gaps.length;

    if (avgRecovery <= fastRecoveryMaxDays + 1) {
      return _createPattern(
        habitId,
        PatternType.fastRecovery,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_fast_recovery',
        {'avg_recovery': avgRecovery},
      );
    } else if (avgRecovery > 5) {
      return _createPattern(
        habitId,
        PatternType.slowRecovery,
        PatternSeverity.medium,
        _calculateConfidence(history.length),
        'pattern_slow_recovery',
        {'avg_recovery': avgRecovery},
      );
    }

    return null;
  }

  List<HabitPattern> _detectWeekdayPerformancePatterns(String habitId, List<HabitCompletion> history) {
    if (history.length < 14) return [];

    final dayCounts = <int, int>{};
    for (int i = 1; i <= 7; i++) {
      dayCounts[i] = 0;
    }

    for (final completion in history) {
      final day = completion.completionDate.weekday;
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }

    int bestDay = 1;
    int worstDay = 1;
    int maxCompletions = -1;
    int minCompletions = 999999;

    dayCounts.forEach((day, count) {
      if (count > maxCompletions) {
        maxCompletions = count;
        bestDay = day;
      }
      if (count < minCompletions) {
        minCompletions = count;
        worstDay = day;
      }
    });

    final patterns = <HabitPattern>[];
    
    // Only add if there's a significant difference or enough data
    if (maxCompletions > minCompletions + 2) {
      patterns.add(_createPattern(
        habitId,
        PatternType.bestDayOfWeek,
        PatternSeverity.low,
        _calculateConfidence(history.length),
        'pattern_best_day',
        {'day': bestDay, 'count': maxCompletions},
      ));
      
      patterns.add(_createPattern(
        habitId,
        PatternType.weakestDayOfWeek,
        PatternSeverity.low,
        _calculateConfidence(history.length),
        'pattern_weakest_day',
        {'day': worstDay, 'count': minCompletions},
      ));
    }

    return patterns;
  }

  PatternConfidence _calculateConfidence(int observations) {
    if (observations >= 30) return PatternConfidence.high;
    if (observations >= 10) return PatternConfidence.medium;
    return PatternConfidence.low;
  }

  HabitPattern _createPattern(
    String habitId,
    PatternType type,
    PatternSeverity severity,
    PatternConfidence confidence,
    String titleKey,
    Map<String, dynamic> metrics,
  ) {
    return HabitPattern(
      id: _uuid.v4(),
      habitId: habitId,
      type: type,
      severity: severity,
      confidence: confidence,
      titleKey: titleKey,
      metrics: metrics,
      detectedAt: DateTime.now(),
    );
  }
}
