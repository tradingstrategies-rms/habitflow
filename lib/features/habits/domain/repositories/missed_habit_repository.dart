import '../entities/missed_habit_event.dart';

/// [MissedHabitRepository] defines the contract for persisting missed habit events.
abstract class MissedHabitRepository {
  /// Saves a new missed habit event.
  Future<void> saveEvent(MissedHabitEvent event);

  /// Retrieves all missed habit events.
  Future<List<MissedHabitEvent>> getEvents();

  /// Retrieves missed events for a specific habit.
  Future<List<MissedHabitEvent>> getEventsForHabit(String habitId);

  /// Marks a specific event as acknowledged.
  Future<void> acknowledgeEvent(String habitId, DateTime scheduledTime);

  /// Deletes an event.
  Future<void> deleteEvent(String habitId, DateTime scheduledTime);
}
