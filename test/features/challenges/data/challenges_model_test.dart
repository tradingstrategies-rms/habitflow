import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/challenges/data/models/challenge_model.dart';
import 'package:habitflow/features/challenges/data/models/challenge_progress_model.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';

void main() {
  group('ChallengeModel', () {
    final challenge = Challenge(
      id: '1',
      title: 'Title',
      description: 'Desc',
      type: ChallengeType.habit,
      difficulty: ChallengeDifficulty.medium,
      targetValue: 5,
      unit: 'times',
      pointReward: 100,
      xpReward: 500,
      startDate: DateTime(2023, 1, 1),
      endDate: DateTime(2023, 12, 31),
    );

    test('fromEntity and toEntity work correctly', () {
      final model = ChallengeModel.fromEntity(challenge);
      expect(model.id, challenge.id);
      expect(model.toEntity().id, challenge.id);
    });

    test('JSON serialization works correctly', () {
      final model = ChallengeModel.fromEntity(challenge);
      final json = model.toJson();
      final fromJson = ChallengeModel.fromJson(json);
      expect(fromJson.id, challenge.id);
      expect(fromJson.title, challenge.title);
    });
  });

  group('ChallengeProgressModel', () {
    final progress = ChallengeProgress(
      challengeId: 'c1',
      profileId: 'p1',
      currentValue: 2,
      isCompleted: false,
      lastUpdatedAt: DateTime.now(),
      periodStartDate: DateTime(2026, 1, 1),
    );

    test('fromEntity and toEntity work correctly', () {
      final model = ChallengeProgressModel.fromEntity(progress);
      expect(model.challengeId, progress.challengeId);
      expect(model.toEntity().challengeId, progress.challengeId);
    });

    test('JSON serialization works correctly', () {
      final model = ChallengeProgressModel.fromEntity(progress);
      final json = model.toJson();
      final fromJson = ChallengeProgressModel.fromJson(json);
      expect(fromJson.challengeId, progress.challengeId);
    });
  });
}
