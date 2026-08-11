import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_consistency_score.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_pattern.dart';
import 'package:habitflow/features/intelligence/domain/services/insight_generation_service.dart';
import 'package:habitflow/features/intelligence/domain/services/pattern_detection_service.dart';
import 'package:habitflow/features/intelligence/domain/services/recommendation_generation_service.dart';

void main() {
  late PatternDetectionService patternDetector;
  late InsightGenerationService insightGenerator;
  late RecommendationGenerationService recommendationGenerator;

  setUp(() {
    patternDetector = PatternDetectionService();
    insightGenerator = InsightGenerationService();
    recommendationGenerator = RecommendationGenerationService();
  });

  final habit = Habit(
    id: 'h1',
    userId: 'u1',
    title: 'Test Habit',
    category: HabitCategory.health,
    icon: HabitIcon.exercise,
    color: HabitColor.emerald,
    priority: HabitPriority.medium,
    frequency: HabitFrequency.daily,
    targetValue: 1.0,
    unit: 'times',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('Advanced Intelligence - Fading Habit', () {
    test('detects declining trend and generates fading habit insight', () {
      final now = DateTime.now();
      final history = List.generate(20, (i) => HabitCompletion(
        id: 'c$i',
        habitId: 'h1',
        completionDate: now.subtract(Duration(days: i)),
        completed: i > 5, // Last 6 days missed
        completedAt: now.subtract(Duration(days: i)),
        createdAt: now.subtract(Duration(days: i)),
      ));

      final metricsRecent = AnalyticsMetrics(
        habitId: 'h1',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
        completedCount: 1,
        activeDays: 1,
        activityRate: 0.14,
        longestStreak: 1,
        averageGapDays: 0.0,
      );
      final metricsBaseline = AnalyticsMetrics(
        habitId: 'h1',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
        completedCount: 7,
        activeDays: 7,
        activityRate: 1.0,
        longestStreak: 7,
        averageGapDays: 1.0,
      );

      final trend = AnalyticsTrend(
        direction: AnalyticsTrendDirection.declining,
        recent: metricsRecent,
        baseline: metricsBaseline,
        delta: -0.86,
      );

      final patterns = patternDetector.detectPatterns(habit: habit, history: history, trend: trend);
      expect(patterns.any((p) => p.type == PatternType.decliningTrend), true);

      final score = HabitConsistencyScore(
        habitId: 'h1',
        overallScore: 40,
        completionScore: 40,
        streakScore: 40,
        stabilityScore: 40,
        recoveryScore: 40,
        calculatedAt: now,
      );

      final insights = insightGenerator.generateInsights(
        habit: habit,
        score: score,
        patterns: patterns,
        trend: trend,
      );

      final fadingInsight = insights.firstWhere((i) => i.title == 'Fading Habit');
      expect(fadingInsight.severity, InsightSeverity.high);

      final recommendations = recommendationGenerator.generateRecommendations(
        habit: habit,
        score: score,
        patterns: patterns,
        insights: insights,
        trend: trend,
      );

      expect(recommendations.any((r) => r.title == 'Emergency Reset'), true);
    });
  });

  group('Advanced Intelligence - Improving Habit', () {
    test('detects improving trend and generates insight', () {
      final now = DateTime.now();
      final history = List.generate(20, (i) => HabitCompletion(
        id: 'c$i',
        habitId: 'h1',
        completionDate: now.subtract(Duration(days: i)),
        completed: i < 7, // Last 7 days completed
        completedAt: now.subtract(Duration(days: i)),
        createdAt: now.subtract(Duration(days: i)),
      ));

      final metricsRecent = AnalyticsMetrics(
        habitId: 'h1',
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
        completedCount: 7,
        activeDays: 7,
        activityRate: 1.0,
        longestStreak: 7,
        averageGapDays: 1.0,
      );
      final metricsBaseline = AnalyticsMetrics(
        habitId: 'h1',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 7)),
        completedCount: 2,
        activeDays: 2,
        activityRate: 0.28,
        longestStreak: 2,
        averageGapDays: 3.0,
      );

      final trend = AnalyticsTrend(
        direction: AnalyticsTrendDirection.improving,
        recent: metricsRecent,
        baseline: metricsBaseline,
        delta: 0.72,
      );

      final patterns = patternDetector.detectPatterns(habit: habit, history: history, trend: trend);
      expect(patterns.any((p) => p.type == PatternType.improvingTrend), true);

      final score = HabitConsistencyScore(
        habitId: 'h1',
        overallScore: 80,
        completionScore: 80,
        streakScore: 80,
        stabilityScore: 80,
        recoveryScore: 80,
        calculatedAt: now,
      );

      final insights = insightGenerator.generateInsights(
        habit: habit,
        score: score,
        patterns: patterns,
        trend: trend,
      );

      expect(insights.any((i) => i.category == InsightCategory.trend && i.title == 'On the Rise'), true);
    });
  });
}
