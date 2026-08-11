import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/shared_habit.dart';
import '../entities/analytics_trend.dart';
import '../entities/family_productivity_score.dart';
import 'analytics_metrics_calculator.dart';

/// Calculates the Family Productivity Score based on habit completions across all family members.
class FamilyProductivityScoreCalculator {
  final AnalyticsMetricsCalculator _metricsCalculator;

  const FamilyProductivityScoreCalculator(this._metricsCalculator);

  /// Calculates a [FamilyProductivityScore] for a given [familyId] and date range.
  /// 
  /// The score is normalized from 0-100 and represents the average performance
  /// of all participating family profiles.
  FamilyProductivityScore calculate({
    required String familyId,
    required List<FamilyProfile> profiles,
    required List<Habit> allHabits,
    required List<SharedHabit> sharedHabits,
    required List<HabitCompletion> allCompletions,
    required DateTime startDate,
    required DateTime endDate,
    FamilyProductivityScore? baselineScore,
  }) {
    if (profiles.isEmpty) {
      return FamilyProductivityScore(
        familyId: familyId,
        score: 0.0,
        startDate: startDate,
        endDate: endDate,
        participatingProfileCount: 0,
        averageActivityRate: 0.0,
        trend: AnalyticsTrendDirection.stable,
        trendDelta: 0.0,
      );
    }

    final profileScores = <double>[];
    final profileActivityRates = <double>[];

    for (final profile in profiles) {
      // Find habits for this profile:
      // 1. Personal habits owned by this profile
      // 2. Shared habits assigned to this profile
      final profileHabits = allHabits.where((h) {
        if (h.userId == profile.id) return true;
        
        // Find if this habit is shared and assigned to this profile
        try {
          final shared = sharedHabits.firstWhere((sh) => sh.habitId == h.id);
          return shared.assignedMemberIds.contains(profile.id);
        } catch (_) {
          return false;
        }
      }).toList();

      if (profileHabits.isEmpty) continue;

      double totalActivityRate = 0.0;
      for (final habit in profileHabits) {
        final metrics = _metricsCalculator.calculate(
          habitId: habit.id,
          startDate: startDate,
          endDate: endDate,
          completions: allCompletions,
        );
        totalActivityRate += metrics.activityRate;
      }

      final avgActivityRate = totalActivityRate / profileHabits.length;
      profileActivityRates.add(avgActivityRate);
      
      // Profile Score = Average activity rate (active days / total days) * 100
      profileScores.add(avgActivityRate * 100);
    }

    if (profileScores.isEmpty) {
      return FamilyProductivityScore(
        familyId: familyId,
        score: 0.0,
        startDate: startDate,
        endDate: endDate,
        participatingProfileCount: profiles.length,
        averageActivityRate: 0.0,
        trend: AnalyticsTrendDirection.stable,
        trendDelta: 0.0,
      );
    }

    // Family Score is the average of individual profile scores
    final familyScore = profileScores.fold(0.0, (a, b) => a + b) / profileScores.length;
    final familyAvgActivityRate = profileActivityRates.fold(0.0, (a, b) => a + b) / profileActivityRates.length;

    AnalyticsTrendDirection trend = AnalyticsTrendDirection.stable;
    double trendDelta = 0.0;

    if (baselineScore != null) {
      trendDelta = familyScore - baselineScore.score;
      // Consistent with AnalyticsTrend threshold (0.05 for 0-1 scale)
      const stableThreshold = 5.0; 

      if (trendDelta > stableThreshold) {
        trend = AnalyticsTrendDirection.improving;
      } else if (trendDelta < -stableThreshold) {
        trend = AnalyticsTrendDirection.declining;
      }
    }

    return FamilyProductivityScore(
      familyId: familyId,
      score: double.parse(familyScore.toStringAsFixed(1)),
      startDate: startDate,
      endDate: endDate,
      participatingProfileCount: profiles.length,
      averageActivityRate: familyAvgActivityRate,
      trend: trend,
      trendDelta: trendDelta,
    );
  }
}
