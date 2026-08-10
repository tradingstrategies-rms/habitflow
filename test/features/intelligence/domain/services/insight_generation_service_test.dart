import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_consistency_score.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_pattern.dart';
import 'package:habitflow/features/intelligence/domain/services/insight_generation_service.dart';

void main() {
  late InsightGenerationService service;

  setUp(() {
    service = InsightGenerationService();
  });

  Habit createTestHabit() {
    return Habit(
      id: 'h1',
      userId: 'u1',
      title: 'Water Plants',
      category: HabitCategory.custom,
      icon: HabitIcon.custom,
      color: HabitColor.emerald,
      priority: HabitPriority.medium,
      frequency: HabitFrequency.daily,
      targetValue: 1.0,
      unit: 'times',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  HabitConsistencyScore createTestScore() {
    return HabitConsistencyScore(
      habitId: 'h1',
      overallScore: 80.0,
      completionScore: 85.0,
      streakScore: 70.0,
      stabilityScore: 90.0,
      recoveryScore: 75.0,
      calculatedAt: DateTime.now(),
    );
  }

  HabitPattern createTestPattern(PatternType type, {PatternSeverity severity = PatternSeverity.medium, Map<String, dynamic>? metrics}) {
    return HabitPattern(
      id: 'p1',
      habitId: 'h1',
      type: type,
      severity: severity,
      confidence: PatternConfidence.high,
      titleKey: 'pattern_key',
      metrics: metrics ?? {},
      detectedAt: DateTime.now(),
    );
  }

  group('InsightGenerationService', () {
    test('generates multiple insights from patterns', () {
      final habit = createTestHabit();
      final score = createTestScore();
      final patterns = [
        createTestPattern(PatternType.morningStrength),
        createTestPattern(PatternType.improvingTrend, severity: PatternSeverity.high),
      ];

      final insights = service.generateInsights(habit: habit, score: score, patterns: patterns);

      expect(insights.length, 2);
      expect(insights.any((i) => i.category == InsightCategory.timing), true);
      expect(insights.any((i) => i.category == InsightCategory.trend), true);
    });

    test('sorts insights by severity', () {
      final habit = createTestHabit();
      final score = createTestScore();
      final patterns = [
        createTestPattern(PatternType.morningStrength, severity: PatternSeverity.low),
        createTestPattern(PatternType.decliningTrend, severity: PatternSeverity.high),
        createTestPattern(PatternType.weekendWeakness, severity: PatternSeverity.medium),
      ];

      final insights = service.generateInsights(habit: habit, score: score, patterns: patterns);

      expect(insights[0].severity, InsightSeverity.high);
      expect(insights[1].severity, InsightSeverity.medium);
      expect(insights[2].severity, InsightSeverity.low);
    });

    test('limits the number of insights to maxInsights', () {
      final habit = createTestHabit();
      final score = createTestScore();
      final patterns = List.generate(
        10,
        (i) => createTestPattern(PatternType.morningStrength, severity: PatternSeverity.low),
      );

      final insights = service.generateInsights(habit: habit, score: score, patterns: patterns);

      expect(insights.length, InsightGenerationService.maxInsights);
    });

    test('correctly handles specific patterns', () {
      final habit = createTestHabit();
      final score = createTestScore();
      
      final pattern = createTestPattern(PatternType.bestDayOfWeek, metrics: {'day': 2}); // Tuesday
      final insights = service.generateInsights(habit: habit, score: score, patterns: [pattern]);

      expect(insights[0].title, 'Power Day');
      expect(insights[0].summary.contains('Tuesday'), true);
    });

    test('returns empty list for no patterns', () {
      final habit = createTestHabit();
      final score = createTestScore();
      final insights = service.generateInsights(habit: habit, score: score, patterns: []);
      expect(insights, isEmpty);
    });
  });
}
