import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:habitflow/features/challenges/domain/services/challenge_lifecycle_service.dart';

void main() {
  final service = ChallengeLifecycleService();
  final startDate = DateTime(2026, 1, 1);
  final endDate = DateTime(2026, 12, 31);

  group('ChallengeLifecycleService', () {
    test('calculateCurrentPeriodStart for daily challenge', () {
      final challenge = Challenge(
        id: '1', title: 'T', description: 'D', type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy, targetValue: 1, unit: 'u',
        pointReward: 1, xpReward: 1, startDate: startDate, endDate: endDate,
        isRecurring: true,
      );
      final now = DateTime(2026, 8, 4, 15, 30);
      final periodStart = service.calculateCurrentPeriodStart(challenge, now);
      expect(periodStart, DateTime(2026, 8, 4));
    });

    test('calculateCurrentPeriodStart for weekly challenge', () {
      final challenge = Challenge(
        id: '1', title: 'T', description: 'D', type: ChallengeType.weekly,
        difficulty: ChallengeDifficulty.easy, targetValue: 1, unit: 'u',
        pointReward: 1, xpReward: 1, startDate: startDate, endDate: endDate,
        isRecurring: true,
      );
      // Aug 4, 2026 is Tuesday. Monday was Aug 3.
      final now = DateTime(2026, 8, 4); 
      final periodStart = service.calculateCurrentPeriodStart(challenge, now);
      expect(periodStart, DateTime(2026, 8, 3));
    });

    test('calculateCurrentPeriodStart for monthly challenge', () {
      final challenge = Challenge(
        id: '1', title: 'T', description: 'D', type: ChallengeType.monthly,
        difficulty: ChallengeDifficulty.easy, targetValue: 1, unit: 'u',
        pointReward: 1, xpReward: 1, startDate: startDate, endDate: endDate,
        isRecurring: true,
      );
      final now = DateTime(2026, 8, 4);
      final periodStart = service.calculateCurrentPeriodStart(challenge, now);
      expect(periodStart, DateTime(2026, 8, 1));
    });

    test('shouldResetProgress returns true if period has changed', () {
      final oldPeriod = DateTime(2026, 8, 3);
      final currentPeriod = DateTime(2026, 8, 4);
      expect(service.shouldResetProgress(oldPeriod, currentPeriod), isTrue);
    });
  });
}
