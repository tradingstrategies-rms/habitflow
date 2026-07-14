/// [HabitReminder] defines a reminder for a habit.
class HabitReminder {
  const HabitReminder({
    required this.id,
    required this.enabled,
    required this.time,
  });

  final String id;
  final bool enabled;
  final DateTime time;
}
