enum SharedHabitCompletionMode {
  everyone,
  anyOne,
  teamGoal;

  String get displayName {
    switch (this) {
      case SharedHabitCompletionMode.everyone:
        return 'Everyone';
      case SharedHabitCompletionMode.anyOne:
        return 'Any One';
      case SharedHabitCompletionMode.teamGoal:
        return 'Team Goal';
    }
  }

  String get description {
    switch (this) {
      case SharedHabitCompletionMode.everyone:
        return 'Every assigned member must complete.';
      case SharedHabitCompletionMode.anyOne:
        return 'First completion completes the habit for all.';
      case SharedHabitCompletionMode.teamGoal:
        return 'Aggregate progress from all members.';
    }
  }
}
