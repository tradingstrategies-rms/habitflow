import 'dart:math';
import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_completion.dart';
import '../../domain/entities/goal.dart';
import '../models/goal_analytics_summary.dart';
import '../models/goal_habit_contribution.dart';

/// [GoalAnalyticsService] performs observation-based analysis on goal data.
class GoalAnalyticsService {
  /// Analyzes a [goal] against a set of [completions] and [habits].
  GoalAnalyticsSummary analyze({
    required Goal goal,
    required List<HabitCompletion> completions,
    required List<Habit> habits,
  }) {
    if (completions.isEmpty) return GoalAnalyticsSummary.empty(goal.id);

    // 1. Filter completions by goal timeframe and habit links
    final relevantCompletions = completions.where((c) {
      final isLinked = goal.habitIds.contains(c.habitId);
      final isAfterStart = !c.completionDate.isBefore(goal.startDate);
      final isBeforeEnd = !c.completionDate.isAfter(goal.endDate);
      return isLinked && isAfterStart && isBeforeEnd && c.completed;
    }).toList();

    if (relevantCompletions.isEmpty) return GoalAnalyticsSummary.empty(goal.id);

    // 2. Calculate Total Days in timeframe (capped by today)
    final now = DateTime.now();
    final effectiveEnd = now.isBefore(goal.endDate) ? now : goal.endDate;
    final totalDays = max(1, effectiveEnd.difference(goal.startDate).inDays + 1);

    // 3. Unique Completion Days
    final completionDates = relevantCompletions
        .map((c) => DateTime(c.completionDate.year, c.completionDate.month, c.completionDate.day))
        .toSet()
        .toList()
      ..sort();
    
    final completedDaysCount = completionDates.length;

    // 4. Streaks
    int currentStreak = 0;
    int bestStreak = 0;
    if (completionDates.isNotEmpty) {
      // Best Streak
      int tempStreak = 1;
      for (int i = 1; i < completionDates.length; i++) {
        if (completionDates[i] == completionDates[i - 1].add(const Duration(days: 1))) {
          tempStreak++;
        } else {
          bestStreak = max(bestStreak, tempStreak);
          tempStreak = 1;
        }
      }
      bestStreak = max(bestStreak, tempStreak);

      // Current Streak (only if last completion is today or yesterday)
      final today = DateTime(now.year, now.month, now.day);
      final lastDate = completionDates.last;
      if (lastDate == today || lastDate == today.subtract(const Duration(days: 1))) {
        int streakCount = 1;
        for (int i = completionDates.length - 2; i >= 0; i--) {
          if (completionDates[i] == completionDates[i + 1].subtract(const Duration(days: 1))) {
            streakCount++;
          } else {
            break;
          }
        }
        currentStreak = streakCount;
      }
    }

    // 5. Completion Rate
    final completionRate = min(1.0, completedDaysCount / totalDays);

    // 6. Average Completion Gap
    double averageGap = 0.0;
    if (completionDates.length > 1) {
      int totalGap = 0;
      for (int i = 1; i < completionDates.length; i++) {
        totalGap += completionDates[i].difference(completionDates[i - 1]).inDays;
      }
      averageGap = totalGap / (completionDates.length - 1);
    }

    // 7. Habit Contributions
    final habitContributions = calculateContributions(
      goal: goal,
      completions: relevantCompletions,
      habits: habits,
    );
    final mostContributing = habitContributions.isNotEmpty 
      ? habitContributions.reduce((a, b) => a.completionCount > b.completionCount ? a : b)
      : null;

    return GoalAnalyticsSummary(
      goalId: goal.id,
      totalDays: totalDays,
      completedDays: completedDaysCount,
      completionRate: completionRate,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      averageCompletionGap: averageGap,
      mostContributingHabit: mostContributing,
      isConsistent: completionRate >= 0.7, // 70% benchmark for consistency
    );
  }

  /// Determines the consistency pattern by day of week.
  String generateInsight({
    required List<HabitCompletion> completions,
  }) {
    if (completions.isEmpty) return 'Start completing habits to see insights.';

    final Map<int, int> weekdayCounts = {};
    for (final c in completions) {
      final weekday = c.completionDate.weekday;
      weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
    }

    int weekdayTotal = 0;
    int weekendTotal = 0;
    for (int i = 1; i <= 5; i++) {
      weekdayTotal += weekdayCounts[i] ?? 0;
    }
    for (int i = 6; i <= 7; i++) {
      weekendTotal += weekdayCounts[i] ?? 0;
    }

    // Normalize by number of days (5 weekdays, 2 weekend days)
    double weekdayAvg = weekdayTotal / 5.0;
    double weekendAvg = weekendTotal / 2.0;

    if (weekdayAvg > weekendAvg * 1.5) {
      return 'You are most consistent on weekdays. Try to keep the momentum on weekends!';
    } else if (weekendAvg > weekdayAvg * 1.5) {
      return 'Great weekend consistency! Keep it up during the busy week.';
    } else if (weekdayAvg > 0 || weekendAvg > 0) {
      return 'You have a steady pace throughout the week. Keep growing!';
    }

    return 'Consistency is the key to growth. You\'re off to a good start!';
  }

  /// Calculates the distribution of habit completions linked to a goal.
  List<GoalHabitContribution> calculateContributions({
    required Goal goal, 
    required List<HabitCompletion> completions,
    required List<Habit> habits,
  }) {
    final Map<String, int> counts = {};
    for (final c in completions) {
      counts[c.habitId] = (counts[c.habitId] ?? 0) + 1;
    }

    final totalCount = completions.length;

    return counts.entries.map((entry) {
      final habitTitle = habits.any((h) => h.id == entry.key)
          ? habits.firstWhere((h) => h.id == entry.key).title
          : 'Deleted Habit';

      return GoalHabitContribution(
        habitId: entry.key,
        habitName: habitTitle,
        completionCount: entry.value,
        percentageContribution: totalCount > 0 ? entry.value / totalCount : 0.0,
      );
    }).toList();
  }
}
