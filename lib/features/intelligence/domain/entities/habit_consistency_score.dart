class HabitConsistencyScore {
  final String habitId;
  final double overallScore;
  final double completionScore;
  final double streakScore;
  final double stabilityScore;
  final double recoveryScore;
  final DateTime calculatedAt;

  const HabitConsistencyScore({
    required this.habitId,
    required this.overallScore,
    required this.completionScore,
    required this.streakScore,
    required this.stabilityScore,
    required this.recoveryScore,
    required this.calculatedAt,
  });
}
