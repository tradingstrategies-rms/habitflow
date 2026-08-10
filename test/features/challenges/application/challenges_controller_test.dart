import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:habitflow/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:habitflow/features/challenges/domain/services/challenge_lifecycle_service.dart';
import 'package:habitflow/features/challenges/application/controllers/challenges_controller.dart';
import 'package:habitflow/features/rewards/application/controllers/rewards_controller.dart';
import 'package:habitflow/core/sync/services/gamification_sync_service.dart';
import 'package:habitflow/core/sync/models/sync_operation.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}
class MockRewardsController extends Mock implements RewardsController {}
class MockChallengeLifecycleService extends Mock implements ChallengeLifecycleService {}
class MockGamificationSyncService extends Mock implements GamificationSyncService {}
class MockRef extends Mock implements Ref {}

final _fallbackProvider = Provider<void>((ref) {});

void main() {
  late ChallengesController controller;
  late MockChallengesRepository mockRepo;
  late MockRewardsController mockRewards;
  late MockChallengeLifecycleService mockLifecycle;
  late MockGamificationSyncService mockSync;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(_fallbackProvider);
  });

  setUp(() {
    mockRepo = MockChallengesRepository();
    mockRewards = MockRewardsController();
    mockLifecycle = MockChallengeLifecycleService();
    mockSync = MockGamificationSyncService();
    mockRef = MockRef();
    controller = ChallengesController(mockRepo, mockRewards, mockLifecycle, mockRef);

    registerFallbackValue(Challenge(
      id: '', title: '', description: '', type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy, targetValue: 1, unit: '',
      pointReward: 0, xpReward: 0, startDate: DateTime.now(), endDate: DateTime.now(),
    ));
    registerFallbackValue(ChallengeProgress(
      challengeId: '',
      profileId: '',
      lastUpdatedAt: DateTime.now(),
      periodStartDate: DateTime.now(),
    ));
    registerFallbackValue(SyncOperation(
      id: '', profileId: '', type: SyncOperationType.addTransaction, data: const {}, createdAt: DateTime.now()
    ));

    when(() => mockRef.read(gamificationSyncServiceProvider)).thenReturn(mockSync);
    when(() => mockSync.queueOperation(any())).thenAnswer((_) async {});
  });

  group('ChallengesController', () {
    final challenge = Challenge(
      id: 'c1',
      title: 'Test',
      description: 'Test',
      type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy,
      targetValue: 5,
      unit: 'times',
      pointReward: 10,
      xpReward: 50,
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );

    final periodStart = DateTime(2026, 8, 1);

    test('updateProgress saves progress and awards rewards on completion', () async {
      when(() => mockRepo.getChallengeById('c1')).thenAnswer((_) async => challenge);
      when(() => mockLifecycle.calculateCurrentPeriodStart(any(), any())).thenReturn(periodStart);
      when(() => mockRepo.getProgress('c1', 'p1', periodStartDate: periodStart)).thenAnswer((_) async => null);
      when(() => mockRepo.saveProgress(any())).thenAnswer((_) async {});
      when(() => mockRewards.awardChallengeCompletion(any(), any(), any(), any(), any()))
          .thenAnswer((_) async {});
      when(() => mockRef.invalidate(any())).thenReturn(null);

      await controller.updateProgress('p1', 'c1', 5.0);

      verify(() => mockRepo.saveProgress(any(that: isA<ChallengeProgress>().having((p) => p.isCompleted, 'isCompleted', true)))).called(1);
      verify(() => mockRewards.awardChallengeCompletion('p1', 'c1', 'Test', 10, 50)).called(1);
    });

    test('incrementProgressByRelatedId updates progress for matching challenges', () async {
      when(() => mockRepo.getActiveChallenges()).thenAnswer((_) async => [challenge.copyWith(relatedId: 'h1')]);
      when(() => mockRepo.getChallengeById('c1')).thenAnswer((_) async => challenge);
      when(() => mockLifecycle.calculateCurrentPeriodStart(any(), any())).thenReturn(periodStart);
      when(() => mockRepo.getProgress('c1', 'p1', periodStartDate: periodStart)).thenAnswer((_) async => null);
      when(() => mockRepo.saveProgress(any())).thenAnswer((_) async {});
      when(() => mockRef.invalidate(any())).thenReturn(null);

      await controller.incrementProgressByRelatedId('p1', 'h1', 1.0);

      verify(() => mockRepo.saveProgress(any())).called(1);
    });
  });
}
