class HabitCompletion {
  final String id;
  final String habitId;
  final String? profileId; // Added for shared habits
  final DateTime completionDate;
  final bool completed;
  final DateTime completedAt;
  final DateTime createdAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    this.profileId,
    required this.completionDate,
    required this.completed,
    required this.completedAt,
    required this.createdAt,
  });
}
