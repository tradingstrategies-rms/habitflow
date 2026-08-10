class RewardCalculationService {
  // Reward Values
  static const int pointsPerHabit = 10;
  static const int xpPerHabit = 50;
  
  static const int pointsPerGoal = 100;
  static const int xpPerGoal = 500;
  
  static const int pointsPerAchievement = 50;
  static const int xpPerAchievement = 200;

  static const int pointsPerStreakMilestone = 25;
  static const int xpPerStreakMilestone = 100;

  /// Calculates the experience required for a given level.
  int calculateExperienceForLevel(int level) {
    if (level <= 1) return 0;
    // Simple exponential curve: 100 * (level - 1) ^ 1.5
    return (100 * (level - 1) * 1.5).toInt();
  }

  /// Determines the level for a given amount of experience.
  int calculateLevelFromExperience(int experience) {
    if (experience <= 0) return 1;
    int level = 1;
    while (calculateExperienceForLevel(level + 1) <= experience) {
      level++;
    }
    return level;
  }

  /// Calculates the progress percentage to the next level.
  double calculateLevelProgress(int experience) {
    final currentLevel = calculateLevelFromExperience(experience);
    final currentLevelXp = calculateExperienceForLevel(currentLevel);
    final nextLevelXp = calculateExperienceForLevel(currentLevel + 1);
    
    final range = nextLevelXp - currentLevelXp;
    final progress = experience - currentLevelXp;
    
    return (progress / range).clamp(0.0, 1.0);
  }
}
