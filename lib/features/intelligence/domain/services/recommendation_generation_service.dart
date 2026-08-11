import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:uuid/uuid.dart';
import '../entities/habit_consistency_score.dart';
import '../entities/habit_insight.dart';
import '../entities/habit_pattern.dart';
import '../entities/habit_recommendation.dart';

/// Service responsible for generating structured recommendations based on habit performance.
class RecommendationGenerationService {
  final _uuid = const Uuid();

  static const int maxRecommendations = 3;

  List<HabitRecommendation> generateRecommendations({
    required Habit habit,
    required HabitConsistencyScore score,
    required List<HabitPattern> patterns,
    required List<HabitInsight> insights,
    AnalyticsTrend? trend,
  }) {
    final recommendations = <HabitRecommendation>[];

    for (final insight in insights) {
      final rec = _mapInsightToRecommendation(habit, insight, score, trend);
      if (rec != null) {
        recommendations.add(rec);
      }
    }

    // Sort by priority (critical first), then supporting insight severity
    recommendations.sort((a, b) {
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;
      
      // If same priority, compare supporting insight severity if available
      if (a.supportingInsights.isNotEmpty && b.supportingInsights.isNotEmpty) {
        return b.supportingInsights.first.severity.index.compareTo(a.supportingInsights.first.severity.index);
      }
      
      return b.generatedAt.compareTo(a.generatedAt);
    });

    // Remove duplicates based on type
    final uniqueRecs = <RecommendationType, HabitRecommendation>{};
    for (final rec in recommendations) {
      if (!uniqueRecs.containsKey(rec.type)) {
        uniqueRecs[rec.type] = rec;
      }
    }

    return uniqueRecs.values.take(maxRecommendations).toList();
  }

  HabitRecommendation? _mapInsightToRecommendation(
    Habit habit, 
    HabitInsight insight, 
    HabitConsistencyScore score,
    AnalyticsTrend? trend,
  ) {
    // We look at the first supporting pattern of the insight to decide the recommendation
    if (insight.supportingPatterns.isEmpty) return null;
    
    final pattern = insight.supportingPatterns.first;

    switch (pattern.type) {
      case PatternType.morningStrength:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.timingAdjustment,
          priority: RecommendationPriority.low,
          title: 'Stick to Mornings',
          summary: 'Your morning consistency is a superpower.',
          reason: 'You are significantly more successful with "${habit.title}" before noon.',
          suggestedAction: 'Keep scheduling this habit in the morning to maintain your momentum.',
          supportingInsights: [insight],
        );
      case PatternType.weekendWeakness:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.scheduleAdjustment,
          priority: RecommendationPriority.medium,
          title: 'Weekend Adjustment',
          summary: 'Adapt your weekend routine.',
          reason: 'Your weekend completion rate is below 40% of your weekday average.',
          suggestedAction: 'Try moving "${habit.title}" to an earlier time on Saturdays and Sundays, or reduce the target volume for weekends.',
          supportingInsights: [insight],
        );
      case PatternType.decliningTrend:
        final isFading = (trend?.delta ?? 0) < -0.2;
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.goalAdjustment,
          priority: isFading ? RecommendationPriority.critical : RecommendationPriority.high,
          title: isFading ? 'Emergency Reset' : 'Mini-Restart',
          summary: isFading ? 'Stop the decline now.' : 'Lower the barrier to entry.',
          reason: isFading ? 'This habit is fading rapidly.' : 'Recent consistency has dropped significantly.',
          suggestedAction: isFading
            ? 'Reduce your "${habit.title}" goal to the absolute minimum (e.g., 1 minute) for the next 14 days to preserve the habit loop.'
            : 'For the next 7 days, aim for a "Minimum Viable" version of "${habit.title}" to rebuild the habit loop.',
          supportingInsights: [insight],
        );
      case PatternType.longInactiveGap:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.restartRoutine,
          priority: RecommendationPriority.critical,
          title: 'Re-Ignite the Spark',
          summary: 'Start fresh today.',
          reason: 'You have been away from this habit for over ${pattern.metrics['max_gap']} days.',
          suggestedAction: 'Resume "${habit.title}" today with the easiest possible step. Don\'t worry about perfection, just show up.',
          supportingInsights: [insight],
        );
      case PatternType.highConsistency:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.maintainMomentum,
          priority: RecommendationPriority.low,
          title: 'Level Up?',
          summary: 'You are crushing it!',
          reason: 'Your consistency score is exceptional.',
          suggestedAction: 'Since you\'ve mastered this routine, consider slightly increasing your target or adding a complementary habit.',
          supportingInsights: [insight],
        );
      case PatternType.fastRecovery:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.celebration,
          priority: RecommendationPriority.low,
          title: 'Resilient Mindset',
          summary: 'Great recovery skills.',
          reason: 'You consistently return to "${habit.title}" immediately after a miss.',
          suggestedAction: 'Keep using your current recovery strategy. This resilience is what makes habits permanent.',
          supportingInsights: [insight],
        );
      case PatternType.lowConsistency:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.habitPairing,
          priority: RecommendationPriority.high,
          title: 'Try Habit Stacking',
          summary: 'Anchor this habit.',
          reason: 'Your current schedule for "${habit.title}" seems inconsistent.',
          suggestedAction: 'Attach "${habit.title}" to an existing, rock-solid part of your day (e.g., "After I brush my teeth, I will ${habit.title}").',
          supportingInsights: [insight],
        );
      case PatternType.improvingTrend:
        return _createRecommendation(
          habitId: habit.id,
          type: RecommendationType.consistencyBoost,
          priority: RecommendationPriority.low,
          title: 'Keep it Up',
          summary: 'Your trend is positive.',
          reason: 'You have increased your completion rate recently.',
          suggestedAction: 'Stay focused on your current streak. You are building lasting change.',
          supportingInsights: [insight],
        );
      default:
        return null;
    }
  }

  HabitRecommendation _createRecommendation({
    required String habitId,
    required RecommendationType type,
    required RecommendationPriority priority,
    required String title,
    required String summary,
    required String reason,
    required String suggestedAction,
    required List<HabitInsight> supportingInsights,
  }) {
    return HabitRecommendation(
      id: _uuid.v4(),
      habitId: habitId,
      type: type,
      priority: priority,
      title: title,
      summary: summary,
      reason: reason,
      suggestedAction: suggestedAction,
      supportingInsights: supportingInsights,
      generatedAt: DateTime.now(),
    );
  }
}
