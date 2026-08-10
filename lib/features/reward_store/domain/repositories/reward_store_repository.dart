import '../entities/reward_item.dart';
import '../entities/reward_redemption.dart';

abstract class RewardStoreRepository {
  Future<List<RewardItem>> getAvailableItems();
  Future<RewardItem?> getItemById(String id);
  Future<List<RewardRedemption>> getRedemptionsByProfile(String profileId);
  Future<List<RewardRedemption>> getAllRedemptions();
  Future<RewardRedemption?> getRedemptionById(String id);
  Future<void> saveRedemption(RewardRedemption redemption);
  Future<void> saveItem(RewardItem item); // Administrative
}
