import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';
import '../../domain/repositories/reward_store_repository.dart';
import '../datasources/reward_store_local_datasource.dart';
import '../models/reward_item_model.dart';
import '../models/reward_redemption_model.dart';

class RewardStoreRepositoryImpl implements RewardStoreRepository {
  final RewardStoreLocalDatasource _datasource;

  RewardStoreRepositoryImpl(this._datasource);

  @override
  Future<List<RewardItem>> getAvailableItems() async {
    final models = await _datasource.getItems();
    return models.where((m) => m.isAvailable).map((m) => m.toEntity()).toList();
  }

  @override
  Future<RewardItem?> getItemById(String id) async {
    final models = await _datasource.getItems();
    try {
      return models.firstWhere((m) => m.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RewardRedemption>> getRedemptionsByProfile(String profileId) async {
    final models = await _datasource.getRedemptions();
    return models.where((m) => m.profileId == profileId).map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RewardRedemption>> getAllRedemptions() async {
    final models = await _datasource.getRedemptions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RewardRedemption?> getRedemptionById(String id) async {
    final models = await _datasource.getRedemptions();
    try {
      return models.firstWhere((m) => m.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveRedemption(RewardRedemption redemption) async {
    await _datasource.saveRedemption(RewardRedemptionModel.fromEntity(redemption));
  }

  @override
  Future<void> saveItem(RewardItem item) async {
    await _datasource.saveItem(RewardItemModel.fromEntity(item));
  }
}
