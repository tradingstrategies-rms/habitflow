import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_pattern.dart';
import 'package:habitflow/features/intelligence/domain/services/pattern_detection_service.dart';

void main() {
  late PatternDetectionService service;

  setUp(() {
    service = PatternDetectionService();
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
      createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    );
  }

  HabitCompletion createCompletion(DateTime date, {bool completed = true, int? hour}) {
    final completionDate = DateTime(date.year, date.month, date.day);
    final completedAt = DateTime(date.year, date.month, date.day, hour ?? 12);
    return HabitCompletion(
      id: 'c_${completedAt.millisecondsSinceEpoch}',
      habitId: 'test_habit',
      completionDate: completionDate,
      completed: completed,
      completedAt: completedAt,
      createdAt: completedAt,
    );
  }

  group('PatternDetectionService', () {
    test('detects morning strength', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = List.generate(10, (i) => createCompletion(now.subtract(Duration(days: i)), hour: 8));
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      final morningPattern = patterns.firstWhere((p) => p.type == PatternType.morningStrength);
      expect(morningPattern.metrics['morning_rate'], 1.0);
    });

    test('detects evening strength', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = List.generate(10, (i) => createCompletion(now.subtract(Duration(days: i)), hour: 20));
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      final eveningPattern = patterns.firstWhere((p) => p.type == PatternType.eveningStrength);
      expect(eveningPattern.metrics['evening_rate'], 1.0);
    });

    test('detects weekday strength', () {
      final habit = createTestHabit();
      // Start from a Monday
      final monday = DateTime(2023, 10, 2); 
      final history = <HabitCompletion>[];
      // 2 weeks of only weekdays
      for (int i = 0; i < 14; i++) {
        final date = monday.add(Duration(days: i));
        if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
          history.add(createCompletion(date));
        }
      }
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.weekdayStrength), true);
    });

    test('detects improving trend', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = <HabitCompletion>[];
      
      // Last 7 days: 100% completion
      for (int i = 0; i < 7; i++) {
        history.add(createCompletion(now.subtract(Duration(days: i))));
      }
      // Previous 23 days (total 30): 20% completion
      for (int i = 7; i < 30; i++) {
        if (i % 5 == 0) {
          history.add(createCompletion(now.subtract(Duration(days: i))));
        }
      }
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.improvingTrend), true);
    });

    test('detects declining trend', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = <HabitCompletion>[];
      
      // Last 7 days: 0% completion
      // Previous 23 days: 100% completion
      for (int i = 7; i < 30; i++) {
        history.add(createCompletion(now.subtract(Duration(days: i))));
      }
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.decliningTrend), true);
    });

    test('detects high consistency', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      // Perfect daily completion for 15 days
      final history = List.generate(15, (i) => createCompletion(now.subtract(Duration(days: i))));
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.highConsistency), true);
    });

    test('detects low consistency', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = [
        createCompletion(now.subtract(const Duration(days: 1))),
        createCompletion(now.subtract(const Duration(days: 5))),
        createCompletion(now.subtract(const Duration(days: 6))),
        createCompletion(now.subtract(const Duration(days: 15))),
        createCompletion(now.subtract(const Duration(days: 16))),
        createCompletion(now.subtract(const Duration(days: 30))),
        createCompletion(now.subtract(const Duration(days: 31))),
        createCompletion(now.subtract(const Duration(days: 45))),
        createCompletion(now.subtract(const Duration(days: 46))),
        createCompletion(now.subtract(const Duration(days: 60))),
      ];
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.lowConsistency), true);
    });

    test('detects long inactive gap', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      final history = [
        createCompletion(now.subtract(const Duration(days: 1))),
        createCompletion(now.subtract(const Duration(days: 10))), // 9 day gap
      ];
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.longInactiveGap), true);
    });

    test('detects fast recovery', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      // Pattern of missing 1 day and returning
      final history = [
        createCompletion(now.subtract(const Duration(days: 1))),
        createCompletion(now.subtract(const Duration(days: 3))),
        createCompletion(now.subtract(const Duration(days: 5))),
        createCompletion(now.subtract(const Duration(days: 7))),
        createCompletion(now.subtract(const Duration(days: 9))),
      ];
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.fastRecovery), true);
    });

    test('detects slow recovery', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      // Pattern of missing many days and returning
      final history = [
        createCompletion(now.subtract(const Duration(days: 1))),
        createCompletion(now.subtract(const Duration(days: 10))),
        createCompletion(now.subtract(const Duration(days: 20))),
        createCompletion(now.subtract(const Duration(days: 30))),
        createCompletion(now.subtract(const Duration(days: 40))),
      ];
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.slowRecovery), true);
    });

    test('detects best and weakest days of week', () {
      final habit = createTestHabit();
      final history = <HabitCompletion>[];
      
      // 5 weeks of data (15 completions total, 15 > 14)
      for (int i = 0; i < 5; i++) {
        final monday = DateTime(2023, 10, 2).add(Duration(days: i * 7));
        history.add(createCompletion(monday)); // Monday
        history.add(createCompletion(monday.add(const Duration(days: 1)))); // Tuesday
        history.add(createCompletion(monday.add(const Duration(days: 2)))); // Wednesday
      }
      
      final patterns = service.detectPatterns(habit: habit, history: history);
      
      expect(patterns.any((p) => p.type == PatternType.bestDayOfWeek), true);
      expect(patterns.any((p) => p.type == PatternType.weakestDayOfWeek), true);
    });

    test('confidence increases with history length', () {
      final habit = createTestHabit();
      final now = DateTime.now();
      
      final shortHistory = List.generate(5, (i) => createCompletion(now.subtract(Duration(days: i)), hour: 8));
      final medHistory = List.generate(15, (i) => createCompletion(now.subtract(Duration(days: i)), hour: 8));
      final longHistory = List.generate(35, (i) => createCompletion(now.subtract(Duration(days: i)), hour: 8));
      
      final shortPatterns = service.detectPatterns(habit: habit, history: shortHistory);
      final medPatterns = service.detectPatterns(habit: habit, history: medHistory);
      final longPatterns = service.detectPatterns(habit: habit, history: longHistory);
      
      expect(shortPatterns.firstWhere((p) => p.type == PatternType.morningStrength).confidence, PatternConfidence.low);
      expect(medPatterns.firstWhere((p) => p.type == PatternType.morningStrength).confidence, PatternConfidence.medium);
      expect(longPatterns.firstWhere((p) => p.type == PatternType.morningStrength).confidence, PatternConfidence.high);
    });

    test('returns empty list for empty history', () {
      final habit = createTestHabit();
      final patterns = service.detectPatterns(habit: habit, history: []);
      expect(patterns, isEmpty);
    });
  });
}
