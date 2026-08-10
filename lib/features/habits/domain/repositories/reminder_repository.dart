import '../entities/habit_reminder.dart';

/// [ReminderRepository] defines the interface for habit reminder persistence.
/// It is responsible for storing and retrieving reminder settings.
abstract class ReminderRepository {
  /// Returns a list of all reminders.
  Future<List<HabitReminder>> getReminders();

  /// Returns the reminder for a specific habit, if it exists.
  Future<HabitReminder?> getReminder(String habitId);

  /// Saves or updates a reminder.
  Future<void> saveReminder(HabitReminder reminder);

  /// Deletes the reminder associated with a habit.
  Future<void> deleteReminder(String habitId);
}
