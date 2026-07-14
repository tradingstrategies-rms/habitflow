/// [CompletionSummary] aggregates completion statistics for a habit.
class CompletionSummary {
  const CompletionSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    this.lastCompletionDate,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final DateTime? lastCompletionDate;
}
