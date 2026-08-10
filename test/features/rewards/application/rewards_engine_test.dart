import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/application/controllers/rewards_controller.dart';
import 'package:habitflow/features/rewards/domain/services/reward_calculation_service.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_calculation_provider.dart';
import 'package:habitflow/core/sync/services/gamification_sync_service.dart';
import 'package:habitflow/core/sync/models/sync_operation.dart';

class MockRewardsRepository extends Mock implements RewardsRepository {}
class MockRef extends Mock implements Ref {}
class MockGamificationSyncService extends Mock implements GamificationSyncService {}

// Use a concrete provider for fallback if ProviderOrFamily is restricted
final _fallbackProvider = Provider<void>((ref) {});

void main() {
  late MockRewardsRepository mockRepository;
  late MockRef mockRef;
  late MockGamificationSyncService mockSync;
  late RewardsController controller;

  setUpAll(() {
    registerFallbackValue(_fallbackProvider);
    registerFallbackValue(RewardAccount(
      profileId: '',
      points: 0,
      experience: 0,
      level: 1,
      lifetimeEarnings: 0,
      lastUpdatedAt: DateTime.now(),
    ));
    registerFallbackValue(SyncOperation(
      id: '', profileId: '', type: SyncOperationType.addTransaction, data: const {}, createdAt: DateTime.now()
    ));
  });

  setUp(() {
    mockRepository = MockRewardsRepository();
    mockRef = MockRef();
    mockSync = MockGamificationSyncService();
    controller = RewardsController(mockRepository, mockRef);
    
    // Invalidate is called by controller, we should mock it
    when(() => mockRef.invalidate(any())).thenReturn(null);
    when(() => mockRef.read(rewardCalculationServiceProvider)).thenReturn(RewardCalculationService());
    when(() => mockRef.read(gamificationSyncServiceProvider)).thenReturn(mockSync);
    when(() => mockSync.queueOperation(any())).thenAnswer((_) async {});
    
    registerFallbackValue(RewardTransaction(
      id: '',
      profileId: '',
      amount: 0,
      type: RewardType.points,
      source: RewardSource.manualAdjustment,
      description: '',
      createdAt: DateTime.now(),
    ));
  });

  group('Rewards Engine Integration', () {
    final now = DateTime.now();
    final account = RewardAccount(
      profileId: 'p1',
      points: 100,
      experience: 200,
      level: 1,
      lifetimeEarnings: 100,
      lastUpdatedAt: now,
    );

    test('awardHabitCompletion awards points and XP and updates account', () async {
      when(() => mockRepository.getAccount('p1')).thenAnswer((_) async => account);
      when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveAccount(any())).thenAnswer((_) async {});

      await controller.awardHabitCompletion('p1', 'h1', 'Drink Water');

      // points + XP transactions
      verify(() => mockRepository.addTransaction(any())).called(2);
      
      // account should be saved twice (once per transaction in the simplified loop)
      verify(() => mockRepository.saveAccount(any())).called(2);
    });

    test('awardAchievement awards correct amounts', () async {
      when(() => mockRepository.getAccount('p1')).thenAnswer((_) async => account);
      when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveAccount(any())).thenAnswer((_) async {});

      await controller.awardAchievement('p1', 'a1', 'First Family');

      verify(() => mockRepository.addTransaction(any(
        that: isA<RewardTransaction>().having((t) => t.source, 'source', RewardSource.achievementUnlocked)
      ))).called(2);
    });
  });
}
