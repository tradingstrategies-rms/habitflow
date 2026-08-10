import 'dart:math';
import '../models/progress_metrics.dart';
import '../models/progress_summary.dart';
import '../../../features/goals/domain/enums/goal_type.dart';

/// Service responsible for calculating progress metrics and summaries.
class ProgressCalculator {
  /// Calculates a [ProgressSummary] based on [metrics] and a [targetValue].
  ProgressSummary calculateSummary(ProgressMetrics metrics, double targetValue) {
    if (targetValue <= 0) {
      // Handle target zero or negative as already completed if any progress exists,
      // or just return 100% if that's the business rule. 
      // Most trackers treat target 0 as invalid or always done.
      return ProgressSummary(
        completedValue: metrics.completionCount.toDouble(),
        targetValue: targetValue,
        percentage: 100.0,
        remaining: 0,
        isCompleted: true,
      );
    }

    double completedValue;
    switch (metrics.type) {
      case GoalType.streak:
        completedValue = metrics.currentStreak.toDouble();
        break;
      case GoalType.numeric:
        completedValue = metrics.totalValue;
        break;
      case GoalType.percentage:
        completedValue = metrics.averageValue;
        break;
      case GoalType.binary:
        completedValue = metrics.completionCount > 0 ? 1.0 : 0.0;
        // For binary, usually target is 1.
        break;
      case GoalType.completionCount:
        completedValue = metrics.completionCount.toDouble();
        break;
    }

    final percentage = min(100.0, (completedValue / targetValue) * 100.0);
    final remaining = max(0.0, targetValue - completedValue);
    final isCompleted = completedValue >= targetValue;

    return ProgressSummary(
      completedValue: completedValue,
      targetValue: targetValue,
      percentage: percentage,
      remaining: remaining,
      isCompleted: isCompleted,
      completionDate: isCompleted ? metrics.lastCompletionDate : null,
    );
  }
}
