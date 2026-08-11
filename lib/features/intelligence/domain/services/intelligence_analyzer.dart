import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/goals/domain/entities/goal.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import '../entities/habit_consistency_score.dart';
import '../entities/habit_insight.dart';
import '../entities/habit_recommendation.dart';
import '../entities/habit_pattern.dart';

abstract class IntelligenceAnalyzer {
  Future<IntelligenceAnalysisResult> analyzeHabit({
    required Habit habit,
    required List<HabitCompletion> history,
    Goal? goal,
    AnalyticsMetrics? metrics,
    AnalyticsTrend? trend,
  });
}

class IntelligenceAnalysisResult {
  final HabitConsistencyScore score;
  final List<HabitInsight> insights;
  final List<HabitRecommendation> recommendations;
  final List<HabitPattern> patterns;

  const IntelligenceAnalysisResult({
    required this.score,
    required this.insights,
    required this.recommendations,
    required this.patterns,
  });
}
