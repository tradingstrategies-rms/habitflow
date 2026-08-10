import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/progress/services/progress_calculator.dart';
import 'package:habitflow/core/progress/services/progress_aggregator.dart';
import 'package:habitflow/core/progress/models/progress_metrics.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/goals/domain/enums/goal_scope.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/domain/enums/goal_type.dart';

void main() {
  final calculator = ProgressCalculator();
  final aggregator = ProgressAggregator(calculator);

  group('ProgressCalculator', () {
    test('calculateSummary should return 100% when target is reached', () {
      const metrics = ProgressMetrics(
        type: GoalType.completionCount,
        completionCount: 10,
      );
      final summary = calculator.calculateSummary(metrics, 10);
      expect(summary.percentage, 100.0);
      expect(summary.isCompleted, true);
    });

    test('calculateSummary should handle zero target', () {
      const metrics = ProgressMetrics(
        type: GoalType.completionCount,
        completionCount: 5,
      );
      final summary = calculator.calculateSummary(metrics, 0);
      expect(summary.percentage, 100.0);
      expect(summary.isCompleted, true);
    });
  });

  group('ProgressAggregator', () {
    final now = DateTime.now();
    final goal = Goal(
      id: 'g1',
      title: 'Aggregator Test',
      description: '',
      habitIds: ['h1'],
      type: GoalType.completionCount,
      scope: GoalScope.daily,
      status: GoalStatus.active,
      targetValue: 2,
      createdAt: now,
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 5)),
      colorValue: 0,
      iconName: '',
    );

    test('aggregate should correctly count completions for linked habits', () {
      final completions = [
        HabitCompletion(
          id: 'c1',
          habitId: 'h1',
          completionDate: now,
          completed: true,
          completedAt: now,
          createdAt: now,
        ),
        HabitCompletion(
          id: 'c2',
          habitId: 'h2', // Not linked
          completionDate: now,
          completed: true,
          completedAt: now,
          createdAt: now,
        ),
      ];

      final summary = aggregator.aggregate(goal, completions);
      expect(summary.completedValue, 1.0);
      expect(summary.percentage, 50.0);
    });
  });
}
