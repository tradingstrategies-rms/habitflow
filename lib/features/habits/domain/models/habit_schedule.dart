/// [HabitSchedule] defines the schedule for a habit.
class HabitSchedule {
  const HabitSchedule({
    required this.daysOfWeek,
    this.timeOfDay,
  });

  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  final DateTime? timeOfDay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitSchedule &&
          runtimeType == other.runtimeType &&
          daysOfWeek == other.daysOfWeek &&
          timeOfDay == other.timeOfDay;

  @override
  int get hashCode => daysOfWeek.hashCode ^ timeOfDay.hashCode;
}
