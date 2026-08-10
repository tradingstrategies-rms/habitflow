import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/intelligence/domain/services/consistency_score_calculator.dart';

void main() {
  late ConsistencyScoreCalculator calculator;

  setUp(() {
    calculator = ConsistencyScoreCalculator();
  });

  Habit createTestHabit({DateTime? createdAt}) {
    return Habit(
      id: 'test_habit',
      userId: 'user_1',
      title: 'Test Habit',
      category: HabitCategory.health,
      icon: HabitIcon.exercise,
      color: HabitColor.blue,
      priority: HabitPriority.high,
      frequency: HabitFrequency.daily,
      targetValue: 1.0,
      unit: 'times',
      createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  HabitCompletion createCompletion(DateTime date, {bool completed = true}) {
    return HabitCompletion(
      id: 'c_${date.millisecondsSinceEpoch}',
      habitId: 'test_habit',
      completionDate: date,
      completed: completed,
      completedAt: date,
      createdAt: date,
    );
  }

  group('ConsistencyScoreCalculator', () {
    test('Perfect habit (100% completion, long streak) should return high score', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      // 31 days of history, all completed
      final history = List.generate(31, (i) => createCompletion(now.subtract(Duration(days: i))));
      
      final score = calculator.calculate(
        habit: habit,
        history: history,
        currentStreak: 31,
      );

      expect(score.overallScore, closeTo(100.0, 0.1));
      expect(score.completionScore, closeTo(100.0, 0.1));
      expect(score.streakScore, 100.0);
      expect(score.stabilityScore, 100.0);
      expect(score.recoveryScore, 100.0);
    });

    test('Zero completion should return zero score', () {
      final habit = createTestHabit();
      
      final score = calculator.calculate(
        habit: habit,
        history: [],
        currentStreak: 0,
      );

      expect(score.overallScore, 0.0);
      expect(score.completionScore, 0.0);
      expect(score.streakScore, 0.0);
      expect(score.stabilityScore, 0.0);
      expect(score.recoveryScore, 0.0);
    });

    test('Streak scoring tiers work correctly', () {
      final habit = createTestHabit();
      
      expect(calculator.calculate(habit: habit, history: [], currentStreak: 7).streakScore, 40.0);
      expect(calculator.calculate(habit: habit, history: [], currentStreak: 14).streakScore, 70.0);
      expect(calculator.calculate(habit: habit, history: [], currentStreak: 30).streakScore, 100.0);
      expect(calculator.calculate(habit: habit, history: [], currentStreak: 45).streakScore, 100.0);
      
      // Interpolation test (midpoint between 0 and 7)
      expect(calculator.calculate(habit: habit, history: [], currentStreak: 4).streakScore, closeTo(22.8, 0.1));
    });

    test('Stability score drops with irregular patterns', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      
      // Stable pattern (every 2nd day)
      final stableHistory = [
        createCompletion(now.subtract(const Duration(days: 6))),
        createCompletion(now.subtract(const Duration(days: 4))),
        createCompletion(now.subtract(const Duration(days: 2))),
      ];
      final stableScore = calculator.calculate(habit: habit, history: stableHistory, currentStreak: 0);

      // Irregular pattern
      final irregularHistory = [
        createCompletion(now.subtract(const Duration(days: 10))),
        createCompletion(now.subtract(const Duration(days: 3))),
        createCompletion(now.subtract(const Duration(days: 2))),
      ];
      final irregularScore = calculator.calculate(habit: habit, history: irregularHistory, currentStreak: 0);

      expect(stableScore.stabilityScore, greaterThan(irregularScore.stabilityScore));
    });

    test('Recovery score measures resilience after misses', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      
      // Quick recovery (1 day gaps)
      final quickHistory = [
        createCompletion(now.subtract(const Duration(days: 5))),
        createCompletion(now.subtract(const Duration(days: 3))), // 1 day gap
        createCompletion(now.subtract(const Duration(days: 1))), // 1 day gap
      ];
      final quickScore = calculator.calculate(habit: habit, history: quickHistory, currentStreak: 1);

      // Slow recovery (4 day gaps)
      final slowHistory = [
        createCompletion(now.subtract(const Duration(days: 10))),
        createCompletion(now.subtract(const Duration(days: 5))), // 4 day gap
        createCompletion(now.subtract(const Duration(days: 1))), // 3 day gap
      ];
      final slowScore = calculator.calculate(habit: habit, history: slowHistory, currentStreak: 1);

      expect(quickScore.recoveryScore, greaterThan(slowScore.recoveryScore));
    });
    
    test('Score values are clamped between 0 and 100', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      
      // Simulate multiple completions per day
      final history = [
        createCompletion(now),
        createCompletion(now),
        createCompletion(now),
      ];
      
      final score = calculator.calculate(habit: habit, history: history, currentStreak: 100);
      
      expect(score.overallScore, lessThanOrEqualTo(100.0));
      expect(score.completionScore, lessThanOrEqualTo(100.0));
      expect(score.streakScore, 100.0);
    });
  });
}
