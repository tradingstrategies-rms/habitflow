import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/analytics/domain/services/analytics_metrics_calculator.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';

void main() {
  const calculator = AnalyticsMetricsCalculator();
  final start = DateTime(2026, 1, 1);
  final end = DateTime(2026, 1, 7);

  HabitCompletion completion(DateTime date, {bool completed = true}) {
    return HabitCompletion(
      id: date.toIso8601String(),
      habitId: 'habit-1',
      completionDate: date,
      completed: completed,
      completedAt: date,
      createdAt: date,
    );
  }

  group('calculate', () {
    test('returns zero metrics for empty history', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: const [],
      );

      expect(result.completedCount, 0);
      expect(result.activeDays, 0);
      expect(result.activityRate, 0);
      expect(result.longestStreak, 0);
      expect(result.averageGapDays, 0);
    });

    test('normalizes duplicate completions to active calendar days', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: [
          completion(DateTime(2026, 1, 2, 8)),
          completion(DateTime(2026, 1, 2, 20)),
          completion(DateTime(2026, 1, 3, 9)),
        ],
      );

      expect(result.completedCount, 3);
      expect(result.activeDays, 2);
      expect(result.longestStreak, 2);
      expect(result.activityRate, closeTo(2 / 7, 0.000001));
      expect(result.averageGapDays, 1);
    });

    test('ignores incomplete, different-habit, and out-of-window events', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: [
          completion(DateTime(2025, 12, 31)),
          completion(DateTime(2026, 1, 2), completed: false),
          HabitCompletion(
            id: 'other',
            habitId: 'habit-2',
            completionDate: DateTime(2026, 1, 3),
            completed: true,
            completedAt: DateTime(2026, 1, 3),
            createdAt: DateTime(2026, 1, 3),
          ),
          completion(DateTime(2026, 1, 4)),
        ],
      );

      expect(result.completedCount, 1);
      expect(result.activeDays, 1);
    });

    test('correctly handles one completion', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: [completion(DateTime(2026, 1, 2))],
      );

      expect(result.completedCount, 1);
      expect(result.activeDays, 1);
      expect(result.longestStreak, 1);
      expect(result.averageGapDays, 0.0);
    });

    test('respects boundary dates strictly', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: [
          completion(start), // On boundary
          completion(end),   // On boundary
        ],
      );

      expect(result.activeDays, 2);
      expect(result.activityRate, closeTo(2 / 7, 0.000001));
    });

    test('calculates longest streak and average gap across multiple days', () {
      final result = calculator.calculate(
        habitId: 'habit-1',
        startDate: start,
        endDate: end,
        completions: [
          completion(DateTime(2026, 1, 1)), // Day 1
          completion(DateTime(2026, 1, 2)), // Day 2 - Streak 2
          completion(DateTime(2026, 1, 4)), // Day 4 - Gap 2 from Day 2
          completion(DateTime(2026, 1, 5)), // Day 5 - Streak 2
          completion(DateTime(2026, 1, 6)), // Day 6 - Streak 3
        ],
      );

      // Unique days: 1, 2, 4, 5, 6
      // Streaks: [1, 2], [4, 5, 6] -> Longest is 3
      // Gaps: (2-1)=1, (4-2)=2, (5-4)=1, (6-5)=1
      // Average Gap: (1+2+1+1) / 4 = 5 / 4 = 1.25
      
      expect(result.activeDays, 5);
      expect(result.longestStreak, 3);
      expect(result.averageGapDays, 1.25);
    });
  });

  group('compare', () {
    AnalyticsMetrics metrics(double rate) => AnalyticsMetrics(
          habitId: 'habit-1',
          startDate: start,
          endDate: end,
          completedCount: 1,
          activeDays: 1,
          activityRate: rate,
          longestStreak: 1,
          averageGapDays: 0,
        );

    test('detects improving, declining and stable trends', () {
      expect(
        calculator.compare(baseline: metrics(0.2), recent: metrics(0.3)).direction,
        AnalyticsTrendDirection.improving,
      );
      expect(
        calculator.compare(baseline: metrics(0.5), recent: metrics(0.4)).direction,
        AnalyticsTrendDirection.declining,
      );
      expect(
        calculator.compare(baseline: metrics(0.5), recent: metrics(0.53)).direction,
        AnalyticsTrendDirection.stable,
      );
    });
  });
}
