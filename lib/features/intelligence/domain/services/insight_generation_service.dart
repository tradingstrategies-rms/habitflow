import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:uuid/uuid.dart';
import '../entities/habit_consistency_score.dart';
import '../entities/habit_insight.dart';
import '../entities/habit_pattern.dart';

/// Service responsible for generating user-facing insights from detected patterns.
class InsightGenerationService {
  final _uuid = const Uuid();

  static const int maxInsights = 5;

  List<HabitInsight> generateInsights({
    required Habit habit,
    required HabitConsistencyScore score,
    required List<HabitPattern> patterns,
  }) {
    final insights = <HabitInsight>[];

    for (final pattern in patterns) {
      final insight = _mapPatternToInsight(habit, pattern, score);
      if (insight != null) {
        insights.add(insight);
      }
    }

    // Sort by severity (high first), then confidence of supporting patterns (if multiple, use average?), 
    // but here we map 1:1 for now.
    // Let's sort by severity and then detectedAt.
    insights.sort((a, b) {
      final severityComparison = b.severity.index.compareTo(a.severity.index);
      if (severityComparison != 0) return severityComparison;
      return b.generatedAt.compareTo(a.generatedAt);
    });

    return insights.take(maxInsights).toList();
  }

  HabitInsight? _mapPatternToInsight(Habit habit, HabitPattern pattern, HabitConsistencyScore score) {
    switch (pattern.type) {
      case PatternType.morningStrength:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.timing,
          severity: InsightSeverity.low,
          title: 'Morning Strength',
          summary: 'You complete this habit most consistently in the morning.',
          explanation: 'Based on your history, you are more likely to succeed when completing "${habit.title}" before noon.',
          supportingPatterns: [pattern],
        );
      case PatternType.eveningStrength:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.timing,
          severity: InsightSeverity.low,
          title: 'Evening Focus',
          summary: 'You tend to complete this habit in the evening.',
          explanation: 'Your patterns show a preference for evening completion for "${habit.title}".',
          supportingPatterns: [pattern],
        );
      case PatternType.weekdayStrength:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.timing,
          severity: InsightSeverity.low,
          title: 'Weekday Warrior',
          summary: 'Your completion rate is higher during the week.',
          explanation: 'You maintain great consistency with "${habit.title}" on weekdays, but there is room to grow on weekends.',
          supportingPatterns: [pattern],
        );
      case PatternType.weekendWeakness:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.medium,
          title: 'Weekend Challenge',
          summary: 'Weekend completion is noticeably lower.',
          explanation: 'It looks like "${habit.title}" often gets missed during the weekend. Consider setting a special weekend reminder.',
          supportingPatterns: [pattern],
        );
      case PatternType.improvingTrend:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.trend,
          severity: InsightSeverity.medium,
          title: 'On the Rise',
          summary: 'Your consistency has improved over the last week.',
          explanation: 'Great job! You are becoming much more consistent with "${habit.title}" compared to previous weeks.',
          supportingPatterns: [pattern],
        );
      case PatternType.decliningTrend:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.high,
          title: 'Slipping Consistency',
          summary: 'Recent performance has declined.',
          explanation: 'You have been less consistent with "${habit.title}" lately. Try to get back on track with a small win today.',
          supportingPatterns: [pattern],
        );
      case PatternType.highConsistency:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.consistency,
          severity: InsightSeverity.high,
          title: 'Rock Solid Routine',
          summary: 'You have built a reliable routine.',
          explanation: 'Your completion of "${habit.title}" is extremely stable. This habit is well-integrated into your life.',
          supportingPatterns: [pattern],
        );
      case PatternType.lowConsistency:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.medium,
          title: 'Irregular Pattern',
          summary: 'Your routine for this habit is currently irregular.',
          explanation: 'Try to complete "${habit.title}" at a similar time each day to build stronger neurological associations.',
          supportingPatterns: [pattern],
        );
      case PatternType.longInactiveGap:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.medium,
          title: 'Extended Break',
          summary: 'This habit has experienced extended breaks.',
          explanation: 'You have had some long gaps in your "${habit.title}" history. Remember that consistency is better than intensity.',
          supportingPatterns: [pattern],
        );
      case PatternType.fastRecovery:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.recovery,
          severity: InsightSeverity.medium,
          title: 'Quick Recovery',
          summary: 'You recover quickly after missing a day.',
          explanation: 'Even when you miss a day of "${habit.title}", you almost always get back to it the next day. This resilience is key!',
          supportingPatterns: [pattern],
        );
      case PatternType.slowRecovery:
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.medium,
          title: 'Slow Recovery',
          summary: 'Lapses often last several days.',
          explanation: 'When you miss "${habit.title}", it tends to take a few days to start again. Try the "never miss twice" rule.',
          supportingPatterns: [pattern],
        );
      case PatternType.bestDayOfWeek:
        final dayName = _getDayName(pattern.metrics['day'] as int);
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.timing,
          severity: InsightSeverity.low,
          title: 'Power Day',
          summary: '$dayName is currently your strongest day.',
          explanation: 'You have a near-perfect record for "${habit.title}" on ${dayName}s.',
          supportingPatterns: [pattern],
        );
      case PatternType.weakestDayOfWeek:
        final dayName = _getDayName(pattern.metrics['day'] as int);
        return _createInsight(
          habitId: habit.id,
          category: InsightCategory.warning,
          severity: InsightSeverity.low,
          title: 'Vulnerable Day',
          summary: '$dayName is often your weakest day.',
          explanation: 'Be extra mindful of "${habit.title}" on ${dayName}s, as this is when you are most likely to miss it.',
          supportingPatterns: [pattern],
        );
      default:
        return null;
    }
  }

  HabitInsight _createInsight({
    required String habitId,
    required InsightCategory category,
    required InsightSeverity severity,
    required String title,
    required String summary,
    required String explanation,
    required List<HabitPattern> supportingPatterns,
  }) {
    return HabitInsight(
      id: _uuid.v4(),
      habitId: habitId,
      category: category,
      severity: severity,
      title: title,
      summary: summary,
      explanation: explanation,
      supportingPatterns: supportingPatterns,
      generatedAt: DateTime.now(),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
}
