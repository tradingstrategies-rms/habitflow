import 'habit_completion.dart';

/// [StreakCalculator] contains pure business logic for streak calculations.
class StreakCalculator {
  static int calculateCurrentStreak(List<HabitCompletion> history, DateTime today) {
    if (history.isEmpty) return 0;

    final sortedDates = history.map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);
    
    // If today is completed, start from today. If not, start from yesterday.
    if (sortedDates.isNotEmpty && sortedDates.first.isBefore(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    for (final date in sortedDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }
    return streak;
  }
}
