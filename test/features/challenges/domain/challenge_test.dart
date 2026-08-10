import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';

void main() {
  group('Challenge', () {
    test('isActive returns true when within date range', () {
      final challenge = Challenge(
        id: '1',
        title: 'Test',
        description: 'Test',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        targetValue: 1,
        unit: 'count',
        pointReward: 10,
        xpReward: 50,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      expect(challenge.isActive, isTrue);
      expect(challenge.isExpired, isFalse);
    });

    test('isExpired returns true when past end date', () {
      final challenge = Challenge(
        id: '1',
        title: 'Test',
        description: 'Test',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        targetValue: 1,
        unit: 'count',
        pointReward: 10,
        xpReward: 50,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(challenge.isExpired, isTrue);
      expect(challenge.isActive, isFalse);
    });
  });
}
