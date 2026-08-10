import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/rewards/data/models/reward_account_model.dart';
import '../../../features/rewards/data/models/reward_transaction_model.dart';
import '../../../features/rewards/data/datasources/remote/rewards_remote_datasource.dart';
import '../../../features/rewards/presentation/providers/rewards_repository_provider.dart';
import '../../../features/challenges/data/models/challenge_progress_model.dart';
import '../../../features/challenges/data/datasources/remote/challenges_remote_datasource.dart';
import '../../../features/challenges/presentation/providers/challenges_repository_provider.dart';
import '../../../features/reward_store/data/models/reward_redemption_model.dart';
import '../../../features/reward_store/data/datasources/remote/reward_store_remote_datasource.dart';
import '../../../features/reward_store/presentation/providers/reward_store_providers.dart';
import '../../../features/authentication/data/auth_providers.dart';
import '../../providers/core_providers.dart';
import '../models/sync_operation.dart';
import '../models/sync_status.dart';
import '../providers/sync_providers.dart';

class GamificationSyncService {
  final Ref _ref;
  bool _isProcessingQueue = false;
  bool _isDisposed = false;
  static const int _maxRetries = 5;
  StreamSubscription<bool>? _connectivitySubscription;

  GamificationSyncService(this._ref) {
    _listenToConnectivity();
    _listenToAuth();
    
    _ref.onDispose(() {
      _isDisposed = true;
      _connectivitySubscription?.cancel();
    });
  }

  void _listenToAuth() {
    _ref.listen(authStateProvider, (previous, next) {
      if (_isDisposed) return;
      if (next.value != null) {
        processQueue();
      }
    });
  }

  void _listenToConnectivity() {
    _ref.listen(connectivityServiceProvider, (previous, next) {
      if (_isDisposed) return;
      _connectivitySubscription?.cancel();
      _connectivitySubscription = next.connectivityStream.listen((connected) {
        if (_isDisposed) return;
        if (connected) {
          _ref.read(syncStatusProvider.notifier).state = SyncStatus.idle;
          processQueue();
        } else {
          _ref.read(syncStatusProvider.notifier).state = SyncStatus.offline;
        }
      });
    }, fireImmediately: true);
  }

  Future<void> queueOperation(SyncOperation operation) async {
    if (_isDisposed) return;
    final userId = _ref.read(authStateProvider).value;
    if (userId == null) return;

    final queueDataSource = _ref.read(syncQueueDataSourceProvider);
    await queueDataSource.addToQueue(userId, operation);
    
    // We don't await processQueue here to avoid blocking callers
    unawaited(processQueue());
  }

  Future<void> processQueue() async {
    if (_isDisposed || _isProcessingQueue) return;
    
    final isConnected = await _ref.read(connectivityServiceProvider).isConnected();
    if (_isDisposed) return;
    if (!isConnected) {
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.offline;
      return;
    }

    final authState = _ref.read(authStateProvider);
    if (_isDisposed) return;
    final userId = authState.value;
    if (userId == null) {
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.failed;
      return;
    }

    _isProcessingQueue = true;
    _ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;

    try {
      final queueDataSource = _ref.read(syncQueueDataSourceProvider);
      var queue = await queueDataSource.getQueue(userId);
      if (_isDisposed) return;
      
      if (queue.isEmpty) {
        _ref.read(syncStatusProvider.notifier).state = SyncStatus.synced;
        return;
      }

      // Optimization: Deduplicate updateAccount operations
      // Only keep the LATEST updateAccount for each profileId
      final dedupedQueue = <SyncOperation>[];
      final latestAccountUpdates = <String, SyncOperation>{};

      for (final op in queue) {
        if (op.type == SyncOperationType.updateAccount) {
          latestAccountUpdates[op.profileId] = op;
        } else {
          dedupedQueue.add(op);
        }
      }
      dedupedQueue.addAll(latestAccountUpdates.values);

      bool anyFailed = false;

      for (final operation in dedupedQueue) {
        if (_isDisposed) return;
        try {
          await _executeRemoteOperation(userId, operation);
          if (_isDisposed) return;
          await queueDataSource.removeFromQueue(userId, operation.id);
        } catch (e, stack) {
          if (_isDisposed) return;
          _ref.read(loggerProvider).error('Sync operation failed', e, stack);
          if (operation.retryCount < _maxRetries) {
            await queueDataSource.updateOperation(userId, operation.copyWith(retryCount: operation.retryCount + 1));
          }
          anyFailed = true;
        }
      }
      
      // Cleanup skipped account updates
      for (final op in queue) {
        if (_isDisposed) return;
        if (op.type == SyncOperationType.updateAccount && latestAccountUpdates[op.profileId]?.id != op.id) {
          await queueDataSource.removeFromQueue(userId, op.id);
        }
      }
      
      if (_isDisposed) return;
      _ref.read(syncStatusProvider.notifier).state = anyFailed ? SyncStatus.failed : SyncStatus.synced;
    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _executeRemoteOperation(String userId, SyncOperation operation) async {
    if (_isDisposed) return;
    switch (operation.type) {
      case SyncOperationType.updateAccount:
        final account = RewardAccountModel.fromJson(operation.data);
        await _ref.read(rewardsRemoteDataSourceProvider).saveAccount(userId, account);
        break;
      case SyncOperationType.addTransaction:
        final transaction = RewardTransactionModel.fromJson(operation.data);
        await _ref.read(rewardsRemoteDataSourceProvider).addTransaction(userId, transaction);
        break;
      case SyncOperationType.updateChallengeProgress:
        final progress = ChallengeProgressModel.fromJson(operation.data);
        await _ref.read(challengesRemoteDataSourceProvider).saveProgress(userId, progress);
        break;
      case SyncOperationType.saveRedemption:
        final redemption = RewardRedemptionModel.fromJson(operation.data);
        await _ref.read(rewardStoreRemoteDataSourceProvider).saveRedemption(userId, redemption);
        break;
    }
  }

  Future<void> syncAll(String profileId) async {
    if (_isDisposed) return;
    final isConnected = await _ref.read(connectivityServiceProvider).isConnected();
    if (_isDisposed) return;
    if (!isConnected) {
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.offline;
      return;
    }

    final authState = _ref.read(authStateProvider);
    if (_isDisposed) return;
    final userId = authState.value;
    if (userId == null) return;

    _ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;

    try {
      await Future.wait([
        _syncRewards(userId, profileId),
        _syncChallenges(userId, profileId),
        _syncRewardStore(userId, profileId),
      ]);
      if (_isDisposed) return;
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.synced;
    } catch (e, stack) {
      _ref.read(loggerProvider).error('syncAll failed', e, stack);
      if (_isDisposed) return;
      _ref.read(syncStatusProvider.notifier).state = SyncStatus.failed;
    }
  }

  Future<void> _syncRewards(String userId, String profileId) async {
    final localRepo = _ref.read(rewardsRepositoryProvider);
    final remoteDataSource = _ref.read(rewardsRemoteDataSourceProvider);

    // Sync Account with Conflict Resolution
    final localAccount = await localRepo.getAccount(profileId);
    final remoteAccount = await remoteDataSource.getAccount(userId, profileId);

    if (localAccount != null) {
      if (remoteAccount == null || localAccount.lastUpdatedAt.isAfter(remoteAccount.lastUpdatedAt)) {
        await remoteDataSource.saveAccount(userId, RewardAccountModel.fromEntity(localAccount));
      } else if (remoteAccount.lastUpdatedAt.isAfter(localAccount.lastUpdatedAt)) {
        await localRepo.saveAccount(remoteAccount);
      }
    } else if (remoteAccount != null) {
      await localRepo.saveAccount(remoteAccount);
    }

    // Sync Transactions (Idempotent upload/download)
    final localTransactions = await localRepo.getTransactions(profileId);
    final remoteTransactions = await remoteDataSource.getTransactions(userId, profileId);

    final remoteIds = remoteTransactions.map((t) => t.id).toSet();
    for (final lt in localTransactions) {
      if (!remoteIds.contains(lt.id)) {
        await remoteDataSource.addTransaction(userId, RewardTransactionModel.fromEntity(lt));
      }
    }

    final localIds = localTransactions.map((t) => t.id).toSet();
    for (final rt in remoteTransactions) {
      if (!localIds.contains(rt.id)) {
        await localRepo.addTransaction(rt);
      }
    }
  }

  Future<void> _syncChallenges(String userId, String profileId) async {
    final localRepo = _ref.read(challengesRepositoryProvider);
    final remoteDataSource = _ref.read(challengesRemoteDataSourceProvider);

    final localProgress = await localRepo.getAllProgressForProfile(profileId);
    final remoteProgress = await remoteDataSource.getProgress(userId, profileId);

    final remoteMap = {for (var p in remoteProgress) '${p.challengeId}_${p.periodStartDate.millisecondsSinceEpoch}': p};
    for (final lp in localProgress) {
      final key = '${lp.challengeId}_${lp.periodStartDate.millisecondsSinceEpoch}';
      final rp = remoteMap[key];
      // Conflict resolution: LWW (Last Write Wins)
      if (rp == null || lp.lastUpdatedAt.isAfter(rp.lastUpdatedAt)) {
        await remoteDataSource.saveProgress(userId, ChallengeProgressModel.fromEntity(lp));
      }
    }

    final localMap = {for (var p in localProgress) '${p.challengeId}_${p.periodStartDate.millisecondsSinceEpoch}': p};
    for (final rp in remoteProgress) {
      final key = '${rp.challengeId}_${rp.periodStartDate.millisecondsSinceEpoch}';
      final lp = localMap[key];
      if (lp == null || rp.lastUpdatedAt.isAfter(lp.lastUpdatedAt)) {
        await localRepo.saveProgress(rp);
      }
    }
  }

  Future<void> _syncRewardStore(String userId, String profileId) async {
    final localRepo = _ref.read(rewardStoreRepositoryProvider);
    final remoteDataSource = _ref.read(rewardStoreRemoteDataSourceProvider);

    final localRedemptions = await localRepo.getRedemptionsByProfile(profileId);
    final remoteRedemptions = await remoteDataSource.getRedemptions(userId, profileId);

    final remoteIds = remoteRedemptions.map((r) => r.id).toSet();
    for (final lr in localRedemptions) {
      if (!remoteIds.contains(lr.id)) {
        await remoteDataSource.saveRedemption(userId, RewardRedemptionModel.fromEntity(lr));
      }
    }

    final localIds = localRedemptions.map((r) => r.id).toSet();
    for (final rr in remoteRedemptions) {
      if (!localIds.contains(rr.id)) {
        await localRepo.saveRedemption(rr);
      }
    }
  }
}

final gamificationSyncServiceProvider = Provider<GamificationSyncService>((ref) {
  return GamificationSyncService(ref);
});
