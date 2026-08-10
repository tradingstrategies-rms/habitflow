import 'dart:math';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';
import '../entities/habit_consistency_score.dart';

/// Service responsible for calculating habit consistency scores based on historical data.
/// 
/// The scoring model is deterministic and rule-based:
/// - Completion Rate (40%)
/// - Current Streak (25%)
/// - Historical Stability (20%)
/// - Recovery Resilience (15%)
class ConsistencyScoreCalculator {
  // Weights for the overall score
  static const double _completionWeight = 0.40;
  static const double _streakWeight = 0.25;
  static const double _stabilityWeight = 0.20;
  static const double _recoveryWeight = 0.15;

  // Streak normalization thresholds
  static const int _streakTier1Days = 7;
  static const double _streakTier1Score = 40.0;
  static const int _streakTier2Days = 14;
  static const double _streakTier2Score = 70.0;
  static const int _streakTier3Days = 30;
  static const double _streakTier3Score = 100.0;

  /// Calculates a [HabitConsistencyScore] for the given habit and its history.
  HabitConsistencyScore calculate({
    required Habit habit,
    required List<HabitCompletion> history,
    required int currentStreak,
  }) {
    final completionScore = _calculateCompletionScore(habit, history);
    final streakScore = _calculateStreakScore(currentStreak);
    final stabilityScore = _calculateStabilityScore(history);
    final recoveryScore = _calculateRecoveryScore(history);

    final overallScore = (completionScore * _completionWeight) +
        (streakScore * _streakWeight) +
        (stabilityScore * _stabilityWeight) +
        (recoveryScore * _recoveryWeight);

    return HabitConsistencyScore(
      habitId: habit.id,
      overallScore: overallScore.clamp(0.0, 100.0),
      completionScore: completionScore.clamp(0.0, 100.0),
      streakScore: streakScore.clamp(0.0, 100.0),
      stabilityScore: stabilityScore.clamp(0.0, 100.0),
      recoveryScore: recoveryScore.clamp(0.0, 100.0),
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculates score based on completion rate in the last 30 days (or since habit start).
  double _calculateCompletionScore(Habit habit, List<HabitCompletion> history) {
    if (history.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final thirtyDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
    final habitStart = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
    
    final effectiveStartDate = habitStart.isAfter(thirtyDaysAgo) ? habitStart : thirtyDaysAgo;
    
    // Calculate expected days in the window
    final daysInWindow = now.difference(effectiveStartDate).inDays + 1;
    if (daysInWindow <= 0) return 0.0;

    final successfulCompletions = history.where((c) {
      if (!c.completed) return false;
      final date = DateTime(c.completionDate.year, c.completionDate.month, c.completionDate.day);
      return date.isAfter(effectiveStartDate.subtract(const Duration(seconds: 1)));
    }).length;

    // Basic completion rate: (actual / days) * 100.
    // Clamped at 100 in case of multiple completions per day (if allowed by system).
    return (successfulCompletions / daysInWindow) * 100;
  }

  /// Normalizes the current streak into a 0-100 score using piecewise linear interpolation.
  double _calculateStreakScore(int streak) {
    if (streak <= 0) return 0.0;
    if (streak >= _streakTier3Days) return _streakTier3Score;

    if (streak <= _streakTier1Days) {
      return (streak / _streakTier1Days) * _streakTier1Score;
    } else if (streak <= _streakTier2Days) {
      const range = _streakTier2Days - _streakTier1Days;
      final progress = streak - _streakTier1Days;
      return _streakTier1Score + (progress / range) * (_streakTier2Score - _streakTier1Score);
    } else {
      const range = _streakTier3Days - _streakTier2Days;
      final progress = streak - _streakTier2Days;
      return _streakTier2Score + (progress / range) * (_streakTier3Score - _streakTier2Score);
    }
  }

  /// Measures consistency of the pattern using variance of gaps between completions.
  double _calculateStabilityScore(List<HabitCompletion> history) {
    final successfulCompletions = history.where((c) => c.completed).toList()
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    if (successfulCompletions.length < 2) {
      return successfulCompletions.length * 50.0; // 0 -> 0, 1 -> 50
    }

    final gaps = <int>[];
    for (int i = 1; i < successfulCompletions.length; i++) {
      final d1 = DateTime(successfulCompletions[i-1].completionDate.year, successfulCompletions[i-1].completionDate.month, successfulCompletions[i-1].completionDate.day);
      final d2 = DateTime(successfulCompletions[i].completionDate.year, successfulCompletions[i].completionDate.month, successfulCompletions[i].completionDate.day);
      gaps.add(d2.difference(d1).inDays);
    }

    final meanGap = gaps.reduce((a, b) => a + b) / gaps.length;
    double variance = 0;
    for (final gap in gaps) {
      variance += pow(gap - meanGap, 2);
    }
    variance /= gaps.length;
    
    final standardDeviation = sqrt(variance);
    
    // High standard deviation = lower stability.
    // A standard deviation of 0 (perfect interval) gives 100.
    // A standard deviation of 3 days significantly reduces the score.
    return (100 - (standardDeviation * 15)).clamp(0.0, 100.0);
  }

  /// Measures how quickly the user recovers from misses.
  double _calculateRecoveryScore(List<HabitCompletion> history) {
    final sorted = history.where((c) => c.completed).toList()
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    if (sorted.isEmpty) return 0.0;

    final missDurations = <int>[];
    
    for (int i = 1; i < sorted.length; i++) {
      final d1 = DateTime(sorted[i-1].completionDate.year, sorted[i-1].completionDate.month, sorted[i-1].completionDate.day);
      final d2 = DateTime(sorted[i].completionDate.year, sorted[i].completionDate.month, sorted[i].completionDate.day);
      final gap = d2.difference(d1).inDays;
      
      if (gap > 1) {
        // A gap of 2 days means 1 day was missed.
        missDurations.add(gap - 1);
      }
    }
    
    if (missDurations.isEmpty) return 100.0; // No misses = perfect recovery resilience
    
    final avgMissDuration = missDurations.reduce((a, b) => a + b) / missDurations.length;
    
    // Score based on average miss duration. 
    // 1 day miss average = 100 score.
    // Higher average = lower score.
    return (100 / avgMissDuration).clamp(0.0, 100.0);
  }
}
