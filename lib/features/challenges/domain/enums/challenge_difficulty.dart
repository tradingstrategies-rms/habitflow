enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  epic;

  String get displayName {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.epic:
        return 'Epic';
    }
  }

  int get rewardMultiplier {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 1;
      case ChallengeDifficulty.medium:
        return 2;
      case ChallengeDifficulty.hard:
        return 3;
      case ChallengeDifficulty.epic:
        return 5;
    }
  }
}
