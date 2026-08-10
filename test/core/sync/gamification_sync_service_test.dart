import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/core/sync/services/gamification_sync_service.dart';
import 'package:habitflow/core/sync/providers/sync_providers.dart';
import 'package:habitflow/core/sync/datasources/sync_queue_datasource.dart';
import 'package:habitflow/core/sync/models/sync_operation.dart';
import 'package:habitflow/core/sync/models/sync_status.dart';
import 'package:habitflow/features/authentication/data/auth_providers.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';
import 'package:habitflow/features/rewards/data/datasources/remote/rewards_remote_datasource.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/data/models/reward_account_model.dart';
import 'package:habitflow/features/rewards/data/models/reward_transaction_model.dart';
import 'package:habitflow/features/challenges/domain/repositories/challenges_repository.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenges_repository_provider.dart';
import 'package:habitflow/features/challenges/data/datasources/remote/challenges_remote_datasource.dart';
import 'package:habitflow/features/reward_store/domain/repositories/reward_store_repository.dart';
import 'package:habitflow/features/reward_store/presentation/providers/reward_store_providers.dart';
import 'package:habitflow/features/reward_store/data/datasources/remote/reward_store_remote_datasource.dart';
import 'package:habitflow/core/services/connectivity/connectivity_service.dart';
import 'package:habitflow/core/providers/core_providers.dart';
import 'package:habitflow/core/services/logger/hf_logger.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';

class MockRewardsRepository extends Mock implements RewardsRepository {}
class MockRewardsRemoteDataSource extends Mock implements RewardsRemoteDataSource {}
class MockChallengesRepository extends Mock implements ChallengesRepository {}
class MockChallengesRemoteDataSource extends Mock implements ChallengesRemoteDataSource {}
class MockRewardStoreRepository extends Mock implements RewardStoreRepository {}
class MockRewardStoreRemoteDataSource extends Mock implements RewardStoreRemoteDataSource {}
class MockSyncQueueDataSource extends Mock implements SyncQueueDataSource {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockHFLogger extends Mock implements HFLogger {}

void main() {
  late ProviderContainer container;
  late MockRewardsRepository mockRewardsLocal;
  late MockRewardsRemoteDataSource mockRewardsRemote;
  late MockChallengesRepository mockChallengesLocal;
  late MockChallengesRemoteDataSource mockChallengesRemote;
  late MockRewardStoreRepository mockRewardStoreLocal;
  late MockRewardStoreRemoteDataSource mockRewardStoreRemote;
  late MockSyncQueueDataSource mockQueue;
  late MockConnectivityService mockConnectivity;
  late MockHFLogger mockLogger;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(RewardAccount(
      profileId: '', points: 0, experience: 0, level: 1, lifetimeEarnings: 0, lastUpdatedAt: DateTime.now()
    ));
    registerFallbackValue(RewardAccountModel(
      profileId: '', points: 0, experience: 0, level: 1, lifetimeEarnings: 0, lastUpdatedAt: DateTime.now()
    ));
    registerFallbackValue(RewardTransactionModel(
      id: '', profileId: '', amount: 0, type: RewardType.points, source: RewardSource.manualAdjustment, description: '', createdAt: DateTime.now()
    ));
    registerFallbackValue(SyncOperation(
      id: '', profileId: '', type: SyncOperationType.addTransaction, data: const {}, createdAt: DateTime.now()
    ));
  });

  setUp(() {
    mockRewardsLocal = MockRewardsRepository();
    mockRewardsRemote = MockRewardsRemoteDataSource();
    mockChallengesLocal = MockChallengesRepository();
    mockChallengesRemote = MockChallengesRemoteDataSource();
    mockRewardStoreLocal = MockRewardStoreRepository();
    mockRewardStoreRemote = MockRewardStoreRemoteDataSource();
    mockQueue = MockSyncQueueDataSource();
    mockConnectivity = MockConnectivityService();
    mockLogger = MockHFLogger();

    when(() => mockQueue.getQueue(any())).thenAnswer((_) async => []);
    when(() => mockConnectivity.isConnected()).thenAnswer((_) async => true);
    when(() => mockConnectivity.connectivityStream).thenAnswer((_) => const Stream.empty());
    
    when(() => mockLogger.error(any(), any(), any())).thenReturn(null);

    container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value('u1')),
      rewardsRepositoryProvider.overrideWithValue(mockRewardsLocal),
      rewardsRemoteDataSourceProvider.overrideWithValue(mockRewardsRemote),
      challengesRepositoryProvider.overrideWithValue(mockChallengesLocal),
      challengesRemoteDataSourceProvider.overrideWithValue(mockChallengesRemote),
      rewardStoreRepositoryProvider.overrideWithValue(mockRewardStoreLocal),
      rewardStoreRemoteDataSourceProvider.overrideWithValue(mockRewardStoreRemote),
      syncQueueDataSourceProvider.overrideWithValue(mockQueue),
      connectivityServiceProvider.overrideWithValue(mockConnectivity),
      loggerProvider.overrideWithValue(mockLogger),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> waitSync(ProviderContainer container) async {
    // Wait for auth to settle
    await container.read(authStateProvider.future);
    // Give some time for background microtasks
    await Future.delayed(Duration.zero);
    // Loop until status is not syncing
    int attempts = 0;
    while (container.read(syncStatusProvider) == SyncStatus.syncing && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 10));
      attempts++;
    }
  }

  group('GamificationSyncService Harding', () {
    test('syncAll uses LWW conflict resolution for accounts', () async {
      final service = container.read(gamificationSyncServiceProvider);
      await waitSync(container);
      
      final now = DateTime.now();
      
      final localAccount = RewardAccount(
        profileId: 'p1', points: 100, experience: 0, level: 1, lifetimeEarnings: 100, 
        lastUpdatedAt: now.subtract(const Duration(minutes: 10))
      );
      final remoteAccount = RewardAccountModel.fromEntity(localAccount.copyWith(
        points: 200, 
        lastUpdatedAt: now.subtract(const Duration(minutes: 5))
      ));

      when(() => mockRewardsLocal.getAccount('p1')).thenAnswer((_) async => localAccount);
      when(() => mockRewardsRemote.getAccount('u1', 'p1')).thenAnswer((_) async => remoteAccount);
      when(() => mockRewardsLocal.saveAccount(any())).thenAnswer((_) async {});
      
      when(() => mockRewardsLocal.getTransactions(any())).thenAnswer((_) async => []);
      when(() => mockRewardsRemote.getTransactions(any(), any())).thenAnswer((_) async => []);
      when(() => mockChallengesLocal.getAllProgressForProfile(any())).thenAnswer((_) async => []);
      when(() => mockChallengesRemote.getProgress(any(), any())).thenAnswer((_) async => []);
      when(() => mockRewardStoreLocal.getRedemptionsByProfile(any())).thenAnswer((_) async => []);
      when(() => mockRewardStoreRemote.getRedemptions(any(), any())).thenAnswer((_) async => []);

      await service.syncAll('p1');

      verify(() => mockRewardsLocal.saveAccount(any(that: isA<RewardAccountModel>().having((a) => a.points, 'points', 200)))).called(1);
    });

    test('processQueue retries failed operations', () async {
      final service = container.read(gamificationSyncServiceProvider);
      await waitSync(container);

      final operation = SyncOperation(
        id: '1', profileId: 'p1', type: SyncOperationType.addTransaction,
        data: const {
          'id': 't1', 
          'profileId': 'p1', 
          'amount': 10, 
          'type': 'points', 
          'source': 'manualAdjustment', 
          'description': 'd', 
          'createdAt': '2026-08-04T10:00:00Z'
        },
        createdAt: DateTime.now()
      );

      when(() => mockQueue.getQueue('u1')).thenAnswer((_) async => [operation]);
      when(() => mockRewardsRemote.addTransaction('u1', any())).thenThrow(Exception('Network error'));
      when(() => mockQueue.updateOperation('u1', any())).thenAnswer((_) async {});

      await service.processQueue();

      verify(() => mockQueue.updateOperation('u1', any(
        that: isA<SyncOperation>().having((o) => o.retryCount, 'retryCount', 1)
      ))).called(1);
      
      expect(container.read(syncStatusProvider), SyncStatus.failed);
    });

    test('queueOperation uses auth state to scope queue', () async {
      final service = container.read(gamificationSyncServiceProvider);
      await waitSync(container);

      final operation = SyncOperation(
        id: '1', profileId: 'p1', type: SyncOperationType.addTransaction,
        data: const {'id': 't1', 'type': 'points', 'source': 'manualAdjustment', 'createdAt': '2026-08-04T10:00:00Z'}, 
        createdAt: DateTime.now()
      );

      when(() => mockQueue.addToQueue('u1', any())).thenAnswer((_) async {});
      
      when(() => mockConnectivity.isConnected()).thenAnswer((_) async => false);

      await service.queueOperation(operation);

      verify(() => mockQueue.addToQueue('u1', operation)).called(1);
    });

    test('partial failure does not stop subsequent operations', () async {
      final service = container.read(gamificationSyncServiceProvider);
      await waitSync(container);

      final op1 = SyncOperation(id: '1', profileId: 'p1', type: SyncOperationType.addTransaction, data: const {'id': 't1', 'type': 'points', 'source': 'manualAdjustment', 'createdAt': '2026-08-04T10:00:00Z'}, createdAt: DateTime.now());
      final op2 = SyncOperation(id: '2', profileId: 'p1', type: SyncOperationType.addTransaction, data: const {'id': 't2', 'type': 'points', 'source': 'manualAdjustment', 'createdAt': '2026-08-04T10:00:00Z'}, createdAt: DateTime.now());

      when(() => mockQueue.getQueue('u1')).thenAnswer((_) async => [op1, op2]);
      when(() => mockRewardsRemote.addTransaction('u1', any(that: isA<RewardTransactionModel>().having((t) => t.id, 'id', 't1')))).thenThrow(Exception('Fail'));
      when(() => mockRewardsRemote.addTransaction('u1', any(that: isA<RewardTransactionModel>().having((t) => t.id, 'id', 't2')))).thenAnswer((_) async {});
      
      when(() => mockQueue.updateOperation('u1', any())).thenAnswer((_) async {});
      when(() => mockQueue.removeFromQueue('u1', '2')).thenAnswer((_) async {});

      await service.processQueue();

      verify(() => mockQueue.updateOperation('u1', any())).called(1);
      verify(() => mockQueue.removeFromQueue('u1', '2')).called(1);
    });

    test('logout/login isolation: queue is scoped by userId', () async {
      final service = container.read(gamificationSyncServiceProvider);
      await waitSync(container);

      await service.processQueue();
      verify(() => mockQueue.getQueue('u1')).called(greaterThanOrEqualTo(1));

      final container2 = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) => Stream.value('u2')),
        syncQueueDataSourceProvider.overrideWithValue(mockQueue),
        connectivityServiceProvider.overrideWithValue(mockConnectivity),
      ]);
      final service2 = container2.read(gamificationSyncServiceProvider);
      await waitSync(container2);

      await service2.processQueue();
      verify(() => mockQueue.getQueue('u2')).called(greaterThanOrEqualTo(1));
    });
  });
}
