import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/goals/analytics/services/goal_analytics_service.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/goals/domain/enums/goal_scope.dart';
import 'package:habitflow/features/goals/domain/enums/goal_status.dart';
import 'package:habitflow/features/goals/domain/enums/goal_type.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';

void main() {
  final service = GoalAnalyticsService();

  group('GoalAnalyticsService', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final goal = Goal(
      id: 'g1',
      title: 'Analytics Test',
      description: '',
      habitIds: ['h1'],
      type: GoalType.completionCount,
      scope: GoalScope.daily,
      status: GoalStatus.active,
      targetValue: 10,
      createdAt: today,
      startDate: today.subtract(const Duration(days: 9)),
      endDate: today.add(const Duration(days: 1)),
      colorValue: 0,
      iconName: '',
    );

    final habit = Habit(
      id: 'h1',
      userId: 'u1',
      title: 'Habit 1',
      category: HabitCategory.health,
      icon: HabitIcon.water,
      color: HabitColor.emerald,
      priority: HabitPriority.medium,
      frequency: HabitFrequency.daily,
      targetValue: 1,
      unit: 'glass',
      createdAt: today,
      updatedAt: today,
    );

    test('analyze should calculate correct completion rate', () {
      final completions = [
        HabitCompletion(
          id: '1',
          habitId: 'h1',
          completionDate: today,
          completed: true,
          completedAt: today,
          createdAt: today,
        ),
      ];

      final summary = service.analyze(
        goal: goal,
        completions: completions,
        habits: [habit],
      );

      // totalDays since start (today - 9 days ago + 1) = 10
      expect(summary.totalDays, 10);
      expect(summary.completedDays, 1);
      expect(summary.completionRate, 0.1);
    });

    test('analyze should calculate streaks correctly', () {
      final yesterday = today.subtract(const Duration(days: 1));
      final completions = [
        HabitCompletion(id: '1', habitId: 'h1', completionDate: yesterday, completed: true, completedAt: yesterday, createdAt: yesterday),
        HabitCompletion(id: '2', habitId: 'h1', completionDate: today, completed: true, completedAt: today, createdAt: today),
      ];

      final summary = service.analyze(
        goal: goal,
        completions: completions,
        habits: [habit],
      );

      expect(summary.currentStreak, 2);
      expect(summary.bestStreak, 2);
    });
  });
}
