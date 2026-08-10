import '../../domain/entities/habit_reminder.dart';
import '../../domain/entities/missed_habit_event.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../../domain/repositories/missed_habit_repository.dart';
import '../../domain/repositories/reminder_repository.dart';

/// [MissedHabitDetectionService] identifies habit reminders that passed their 
/// scheduled time without a recorded completion.
class MissedHabitDetectionService {
  final ReminderRepository _reminderRepository;
  final HabitCompletionRepository _completionRepository;
  final MissedHabitRepository _missedHabitRepository;

  /// The default grace period before a habit is considered "missed".
  static const Duration defaultGracePeriod = Duration(minutes: 60);

  /// Creates a [MissedHabitDetectionService].
  MissedHabitDetectionService({
    required this._reminderRepository,
    required this._completionRepository,
    required this._missedHabitRepository,
  });

  /// Scans all enabled reminders and creates missed events for any that passed 
  /// their scheduled time without a corresponding completion.
  Future<void> detectMissedHabits({Duration gracePeriod = defaultGracePeriod}) async {
    final now = DateTime.now();
    final reminders = await _reminderRepository.getReminders();

    for (final reminder in reminders) {
      if (!reminder.enabled) continue;

      final scheduledTime = _getMostRecentOccurrence(reminder, now);
      if (scheduledTime == null) continue;

      // Check if we are past the grace period
      if (now.isBefore(scheduledTime.add(gracePeriod))) continue;

      // Check if already completed on that day
      final completions = await _completionRepository.getCompletionsForHabit(reminder.habitId);
      final isCompleted = completions.any((c) => 
        c.completionDate.year == scheduledTime.year && 
        c.completionDate.month == scheduledTime.month &&
        c.completionDate.day == scheduledTime.day
      );

      if (!isCompleted) {
        // Log the missed event if it doesn't already exist
        await _missedHabitRepository.saveEvent(MissedHabitEvent(
          habitId: reminder.habitId,
          reminderId: reminder.id,
          scheduledTime: scheduledTime,
          detectedAt: now,
        ));
      }
    }
  }

  /// Calculates the most recent scheduled occurrence for a reminder relative to [now].
  DateTime? _getMostRecentOccurrence(HabitReminder reminder, DateTime now) {
    DateTime? occurrence;

    switch (reminder.repeatType) {
      case ReminderRepeatType.daily:
        occurrence = _occurrenceOnDay(reminder, now);
        if (occurrence.isAfter(now)) {
          occurrence = occurrence.subtract(const Duration(days: 1));
        }
        break;
      case ReminderRepeatType.selectedWeekdays:
        // Look back up to 7 days to find the most recent matching weekday
        for (int i = 0; i < 7; i++) {
          final candidateDay = now.subtract(Duration(days: i));
          if (reminder.weekdays.contains(candidateDay.weekday)) {
            final candidateOccurrence = _occurrenceOnDay(reminder, candidateDay);
            if (candidateOccurrence.isBefore(now) || candidateOccurrence.isAtSameMomentAs(now)) {
              occurrence = candidateOccurrence;
              break;
            }
          }
        }
        break;
      case ReminderRepeatType.once:
        final candidate = _occurrenceOnDay(reminder, reminder.createdAt);
        if (candidate.isBefore(now)) {
          occurrence = candidate;
        }
        break;
    }

    return occurrence;
  }

  DateTime _occurrenceOnDay(HabitReminder reminder, DateTime day) {
    return DateTime(
      day.year,
      day.month,
      day.day,
      reminder.timeOfDay.hour,
      reminder.timeOfDay.minute,
    );
  }
}
