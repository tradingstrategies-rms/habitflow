import '../../../features/goals/domain/entities/goal.dart';
import '../../../features/habits/domain/entities/habit_completion.dart';
import '../../../features/goals/domain/enums/goal_type.dart';
import '../models/progress_metrics.dart';
import '../models/progress_summary.dart';
import 'progress_calculator.dart';

/// Service responsible for aggregating completion data into metrics.
class ProgressAggregator {
  final ProgressCalculator _calculator;

  ProgressAggregator(this._calculator);

  /// Aggregates [completions] for a specific [goal] into a [ProgressSummary].
  ProgressSummary aggregate(Goal goal, List<HabitCompletion> completions) {
    // 1. Filter completions for the goal's habits and timeframe
    // and remove duplicates (same habit on same day)
    final Set<String> seenCompletions = {};
    final relevantCompletions = completions.where((c) {
      final dateKey = '${c.habitId}_${c.profileId ?? ''}_${c.completionDate.year}_${c.completionDate.month}_${c.completionDate.day}';
      if (seenCompletions.contains(dateKey)) return false;

      final isLinkedHabit = goal.habitIds.contains(c.habitId);
      final isWithinTimeframe = !c.completionDate.isBefore(goal.startDate) &&
          !c.completionDate.isAfter(goal.endDate);
      
      final isValid = isLinkedHabit && isWithinTimeframe && c.completed;
      if (isValid) {
        seenCompletions.add(dateKey);
      }
      return isValid;
    }).toList();

    if (relevantCompletions.isEmpty) {
      return ProgressSummary.zero(goal.targetValue);
    }

    // 2. Calculate metrics based on GoalType
    final metrics = _calculateMetrics(goal, relevantCompletions);

    // 3. Return calculated summary
    return _calculator.calculateSummary(metrics, goal.targetValue);
  }

  ProgressMetrics _calculateMetrics(Goal goal, List<HabitCompletion> completions) {
    int completionCount = completions.length;
    double totalValue = completions.length.toDouble(); // Assuming 1 completion = 1.0 value
    
    // Find last completion date
    DateTime? lastCompletionDate;
    if (completions.isNotEmpty) {
      lastCompletionDate = completions
          .map((c) => c.completionDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
    
    // For streak, we need to look at completion by date
    int currentStreak = 0;
    int maxStreak = 0;
    
    if (goal.type == GoalType.streak) {
      final completionDates = completions
          .map((c) => DateTime(c.completionDate.year, c.completionDate.month, c.completionDate.day))
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // Sort descending to find current streak

      if (completionDates.isNotEmpty) {
        // Current Streak (starting from today or the latest completion)
        // Note: For simplicity, we define streak as consecutive days of ANY linked habit completion.
        // A more advanced version would require ALL linked habits to be completed.
        
        DateTime expectedDate = completionDates.first;
        currentStreak = 1;
        
        for (int i = 1; i < completionDates.length; i++) {
          if (completionDates[i] == expectedDate.subtract(const Duration(days: 1))) {
            currentStreak++;
            expectedDate = completionDates[i];
          } else {
            break;
          }
        }
        
        // Max Streak
        int tempStreak = 1;
        List<DateTime> sortedAsc = completionDates.reversed.toList();
        for (int i = 1; i < sortedAsc.length; i++) {
          if (sortedAsc[i] == sortedAsc[i-1].add(const Duration(days: 1))) {
            tempStreak++;
          } else {
            if (tempStreak > maxStreak) maxStreak = tempStreak;
            tempStreak = 1;
          }
        }
        if (tempStreak > maxStreak) maxStreak = tempStreak;
      }
    }

    double averageValue = 0.0;
    if (goal.type == GoalType.percentage) {
      // For percentage, maybe completions vs possible completions?
      // But we don't have the habit frequency here.
      // We'll assume percentage is based on the targetValue.
      // If target is 100, and we have 50 completions, it's 50%.
      // Actually the Calculator handles the percentage math.
      averageValue = totalValue; 
    }

    return ProgressMetrics(
      type: goal.type,
      completionCount: completionCount,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      totalValue: totalValue,
      averageValue: averageValue,
      lastCompletionDate: lastCompletionDate,
    );
  }
}
