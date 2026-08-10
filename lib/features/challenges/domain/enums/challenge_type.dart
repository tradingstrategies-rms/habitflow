enum ChallengeType {
  daily,
  weekly,
  monthly,
  habit,
  goal,
  family,
  seasonal;

  String get displayName {
    switch (this) {
      case ChallengeType.daily:
        return 'Daily';
      case ChallengeType.weekly:
        return 'Weekly';
      case ChallengeType.monthly:
        return 'Monthly';
      case ChallengeType.habit:
        return 'Habit';
      case ChallengeType.goal:
        return 'Goal';
      case ChallengeType.family:
        return 'Family';
      case ChallengeType.seasonal:
        return 'Seasonal';
    }
  }
}
