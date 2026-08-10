import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/challenges/data/repositories/challenges_repository_impl.dart';
import 'package:habitflow/features/challenges/data/datasources/challenges_local_datasource.dart';
import 'package:habitflow/features/challenges/data/models/challenge_model.dart';
import 'package:habitflow/features/challenges/data/models/challenge_progress_model.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';

class MockChallengesLocalDatasource extends Mock implements ChallengesLocalDatasource {}

void main() {
  late ChallengesRepositoryImpl repository;
  late MockChallengesLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockChallengesLocalDatasource();
    repository = ChallengesRepositoryImpl(mockDatasource);
    
    registerFallbackValue(ChallengeModel(
      id: '',
      title: '',
      description: '',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy,
      targetValue: 0,
      unit: '',
      pointReward: 0,
      xpReward: 0,
      startDate: DateTime.now(),
      endDate: DateTime.now(),
    ));

    registerFallbackValue(ChallengeProgressModel(
      challengeId: '',
      profileId: '',
      lastUpdatedAt: DateTime.now(),
      periodStartDate: DateTime.now(),
    ));
  });

  group('ChallengesRepositoryImpl', () {
    final challenge = Challenge(
      id: '1',
      title: 'T',
      description: 'D',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy,
      targetValue: 1,
      unit: 'u',
      pointReward: 10,
      xpReward: 50,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );

    test('getActiveChallenges returns only active challenges', () async {
      final expired = ChallengeModel.fromEntity(challenge).modelCopyWith(
        id: '2',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
      );
      
      when(() => mockDatasource.getChallenges()).thenAnswer((_) async => [
        ChallengeModel.fromEntity(challenge),
        expired,
      ]);

      final result = await repository.getActiveChallenges();

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('saveProgress calls datasource', () async {
      final progress = ChallengeProgress(
        challengeId: 'c1',
        profileId: 'p1',
        lastUpdatedAt: DateTime.now(),
        periodStartDate: DateTime.now(),
      );
      
      when(() => mockDatasource.saveProgress(any())).thenAnswer((_) async {});

      await repository.saveProgress(progress);

      verify(() => mockDatasource.saveProgress(any())).called(1);
    });
  });
}

// Fix copyWith on Model if not available or use constructor
extension on ChallengeModel {
  ChallengeModel modelCopyWith({String? id, DateTime? startDate, DateTime? endDate}) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title,
      description: description,
      type: type,
      difficulty: difficulty,
      targetValue: targetValue,
      unit: unit,
      pointReward: pointReward,
      xpReward: xpReward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
