import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/enums/redemption_status.dart';
import '../../domain/repositories/reward_store_repository.dart';
import '../../data/datasources/reward_store_local_datasource.dart';
import '../../data/repositories/reward_store_repository_impl.dart';
import '../../application/controllers/reward_store_controller.dart';
import '../../../rewards/presentation/providers/rewards_controller_provider.dart';

final rewardStoreDataSourceProvider = Provider<RewardStoreLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RewardStoreLocalDatasourceImpl(prefs);
});

final rewardStoreRepositoryProvider = Provider<RewardStoreRepository>((ref) {
  final dataSource = ref.watch(rewardStoreDataSourceProvider);
  return RewardStoreRepositoryImpl(dataSource);
});

final rewardStoreControllerProvider = Provider<RewardStoreController>((ref) {
  final repository = ref.watch(rewardStoreRepositoryProvider);
  final rewardsController = ref.watch(rewardsControllerProvider);
  return RewardStoreController(repository, rewardsController, ref);
});

final rewardCatalogProvider = FutureProvider<List<RewardItem>>((ref) async {
  final repository = ref.watch(rewardStoreRepositoryProvider);
  return await repository.getAvailableItems();
});

final rewardItemByIdProvider = FutureProvider.family<RewardItem?, String>((ref, id) async {
  final repository = ref.watch(rewardStoreRepositoryProvider);
  return await repository.getItemById(id);
});

final redemptionHistoryProvider = FutureProvider.family<List<RewardRedemption>, String>((ref, profileId) async {
  final repository = ref.watch(rewardStoreRepositoryProvider);
  return await repository.getRedemptionsByProfile(profileId);
});

final allRedemptionsProvider = FutureProvider<List<RewardRedemption>>((ref) async {
  final repository = ref.watch(rewardStoreRepositoryProvider);
  return await repository.getAllRedemptions();
});

final pendingRedemptionsProvider = Provider<List<RewardRedemption>>((ref) {
  final allAsync = ref.watch(allRedemptionsProvider);
  return allAsync.maybeWhen(
    data: (list) => list.where((r) => r.status == RedemptionStatus.pending).toList(),
    orElse: () => [],
  );
});

final approvedRedemptionsProvider = Provider<List<RewardRedemption>>((ref) {
  final allAsync = ref.watch(allRedemptionsProvider);
  return allAsync.maybeWhen(
    data: (list) => list.where((r) => r.status == RedemptionStatus.approved).toList(),
    orElse: () => [],
  );
});
