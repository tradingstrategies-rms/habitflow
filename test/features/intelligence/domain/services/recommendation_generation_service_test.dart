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
import 'package:habitflow/features/intelligence/domain/entities/habit_recommendation.dart';
import 'package:habitflow/features/intelligence/domain/services/recommendation_generation_service.dart';

void main() {
  late RecommendationGenerationService service;

  setUp(() {
    service = RecommendationGenerationService();
  });

  Habit createTestHabit() {
    return Habit(
      id: 'h1',
      userId: 'u1',
      title: 'Meditation',
      category: HabitCategory.mindfulness,
      icon: HabitIcon.meditation,
      color: HabitColor.blue,
      priority: HabitPriority.medium,
      frequency: HabitFrequency.daily,
      targetValue: 1.0,
      unit: 'times',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  HabitConsistencyScore createTestScore({double overall = 70.0}) {
    return HabitConsistencyScore(
      habitId: 'h1',
      overallScore: overall,
      completionScore: 75.0,
      streakScore: 60.0,
      stabilityScore: 80.0,
      recoveryScore: 70.0,
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

  HabitInsight createTestInsight(HabitPattern pattern, {InsightSeverity severity = InsightSeverity.medium}) {
    return HabitInsight(
      id: 'i1',
      habitId: 'h1',
      category: InsightCategory.general,
      severity: severity,
      title: 'Test Insight',
      summary: 'Test Summary',
      explanation: 'Test Explanation',
      supportingPatterns: [pattern],
      generatedAt: DateTime.now(),
    );
  }

  group('RecommendationGenerationService', () {
    test('generates critical recommendation for long inactive gap', () {
      final habit = createTestHabit();
      final score = createTestScore(overall: 20.0);
      final pattern = createTestPattern(PatternType.longInactiveGap, metrics: {'max_gap': 10});
      final insight = createTestInsight(pattern, severity: InsightSeverity.high);

      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: [pattern],
        insights: [insight],
      );

      expect(recommendations.length, 1);
      expect(recommendations[0].priority, RecommendationPriority.critical);
      expect(recommendations[0].type, RecommendationType.restartRoutine);
      expect(recommendations[0].title, 'Re-Ignite the Spark');
    });

    test('generates low priority recommendation for high consistency', () {
      final habit = createTestHabit();
      final score = createTestScore(overall: 95.0);
      final pattern = createTestPattern(PatternType.highConsistency);
      final insight = createTestInsight(pattern, severity: InsightSeverity.high);

      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: [pattern],
        insights: [insight],
      );

      expect(recommendations.length, 1);
      expect(recommendations[0].priority, RecommendationPriority.low);
      expect(recommendations[0].type, RecommendationType.maintainMomentum);
    });

    test('sorts recommendations by priority (critical first)', () {
      final habit = createTestHabit();
      final score = createTestScore();
      
      final p1 = createTestPattern(PatternType.highConsistency);
      final i1 = createTestInsight(p1, severity: InsightSeverity.low);
      
      final p2 = createTestPattern(PatternType.longInactiveGap, metrics: {'max_gap': 5});
      final i2 = createTestInsight(p2, severity: InsightSeverity.high);
      
      final p3 = createTestPattern(PatternType.decliningTrend);
      final i3 = createTestInsight(p3, severity: InsightSeverity.medium);

      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: [p1, p2, p3],
        insights: [i1, i2, i3],
      );

      expect(recommendations[0].priority, RecommendationPriority.critical);
      expect(recommendations[1].priority, RecommendationPriority.high);
      expect(recommendations[2].priority, RecommendationPriority.low);
    });

    test('limits to maxRecommendations (3)', () {
      final habit = createTestHabit();
      final score = createTestScore();
      
      final patterns = [
        createTestPattern(PatternType.morningStrength),
        createTestPattern(PatternType.weekendWeakness),
        createTestPattern(PatternType.decliningTrend),
        createTestPattern(PatternType.fastRecovery),
      ];
      final insights = patterns.map((p) => createTestInsight(p)).toList();

      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: patterns,
        insights: insights,
      );

      expect(recommendations.length, 3);
    });

    test('suppresses duplicate recommendation types', () {
      final habit = createTestHabit();
      final score = createTestScore();
      
      // Both morning and evening strength map to timingAdjustment
      final p1 = createTestPattern(PatternType.morningStrength);
      final p2 = createTestPattern(PatternType.eveningStrength);
      
      final insights = [createTestInsight(p1), createTestInsight(p2)];

      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: [p1, p2],
        insights: insights,
      );

      expect(recommendations.length, 1);
      expect(recommendations[0].type, RecommendationType.timingAdjustment);
    });

    test('returns empty list for no insights/patterns', () {
      final habit = createTestHabit();
      final score = createTestScore();
      final recommendations = service.generateRecommendations(
        habit: habit,
        score: score,
        patterns: [],
        insights: [],
      );
      expect(recommendations, isEmpty);
    });
  });
}
