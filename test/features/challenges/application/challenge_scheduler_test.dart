import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:habitflow/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:habitflow/features/challenges/domain/services/challenge_lifecycle_service.dart';
import 'package:habitflow/features/challenges/application/services/challenge_scheduler.dart';

class MockChallengesRepository extends Mock implements ChallengesRepository {}
class MockChallengeLifecycleService extends Mock implements ChallengeLifecycleService {}
class MockRef extends Mock implements Ref {}

final _fallbackProvider = Provider<void>((ref) {});

void main() {
  late ChallengeScheduler scheduler;
  late MockChallengesRepository mockRepo;
  late MockChallengeLifecycleService mockLifecycle;
  late MockRef mockRef;

  setUpAll(() {
    registerFallbackValue(_fallbackProvider);
  });

  setUp(() {
    mockRepo = MockChallengesRepository();
    mockLifecycle = MockChallengeLifecycleService();
    mockRef = MockRef();
    scheduler = ChallengeScheduler(mockRepo, mockLifecycle, mockRef);

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
  });

  test('evaluateChallenges initializes new period progress for recurring challenges', () async {
    final challenge = Challenge(
      id: 'c1', title: 'T', description: 'D', type: ChallengeType.daily,
      difficulty: ChallengeDifficulty.easy, targetValue: 1, unit: 'u',
      pointReward: 1, xpReward: 1, 
      startDate: DateTime.now().subtract(const Duration(days: 1)), 
      endDate: DateTime.now().add(const Duration(days: 1)),
      isRecurring: true,
    );

    final periodStart = DateTime(2026, 8, 4);

    when(() => mockRepo.getActiveChallenges()).thenAnswer((_) async => [challenge]);
    when(() => mockRepo.getAllProgressForProfile('p1')).thenAnswer((_) async => []);
    when(() => mockLifecycle.isChallengeActive(any(), any())).thenReturn(true);
    when(() => mockLifecycle.calculateCurrentPeriodStart(any(), any())).thenReturn(periodStart);
    when(() => mockRepo.saveProgress(any())).thenAnswer((_) async {});
    when(() => mockRef.invalidate(any())).thenReturn(null);

    await scheduler.evaluateChallenges('p1');

    verify(() => mockRepo.saveProgress(any(
      that: isA<ChallengeProgress>().having((p) => p.periodStartDate, 'periodStartDate', periodStart)
    ))).called(1);
  });
}
