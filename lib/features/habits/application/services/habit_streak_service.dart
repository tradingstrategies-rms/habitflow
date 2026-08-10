import '../../domain/entities/habit_completion.dart';

class HabitStreakService {
  int calculateCurrentStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;

    // Sort completions by date descending
    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    DateTime lastDate = todayStart;

    // Check if the most recent completion is today or yesterday
    final firstCompletionDate = sorted.first.completionDate;
    final firstDateOnly = DateTime(firstCompletionDate.year, firstCompletionDate.month, firstCompletionDate.day);
    
    if (firstDateOnly != todayStart && firstDateOnly != todayStart.subtract(const Duration(days: 1))) {
      return 0;
    }

    lastDate = firstDateOnly;
    streak = 1;

    for (int i = 1; i < sorted.length; i++) {
      final currentDate = sorted[i].completionDate;
      final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (currentDateOnly == lastDate.subtract(const Duration(days: 1))) {
        streak++;
        lastDate = currentDateOnly;
      } else if (currentDateOnly == lastDate) {
        // Skip same day duplicates
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  int calculateBestStreak(List<HabitCompletion> completions) {
    if (completions.isEmpty) return 0;

    final sorted = List<HabitCompletion>.from(completions)
      ..sort((a, b) => a.completionDate.compareTo(b.completionDate));

    int bestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final completion in sorted) {
      final dateOnly = DateTime(
          completion.completionDate.year,
          completion.completionDate.month,
          completion.completionDate.day);

      if (lastDate == null) {
        currentStreak = 1;
      } else if (dateOnly == lastDate.add(const Duration(days: 1))) {
        currentStreak++;
      } else if (dateOnly == lastDate) {
        continue;
      } else {
        currentStreak = 1;
      }

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
      lastDate = dateOnly;
    }

    return bestStreak;
  }

  double calculateCompletionPercentage(List<HabitCompletion> completions, int lastDays) {
    if (completions.isEmpty) return 0.0;

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: lastDays));
    
    final relevantCompletions = completions.where((c) => c.completionDate.isAfter(startDate)).length;
    
    return (relevantCompletions / lastDays) * 100;
  }
}
