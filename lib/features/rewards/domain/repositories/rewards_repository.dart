import '../entities/reward_account.dart';
import '../entities/reward_transaction.dart';

abstract class RewardsRepository {
  Future<RewardAccount?> getAccount(String profileId);
  Future<void> saveAccount(RewardAccount account);
  Future<List<RewardTransaction>> getTransactions(String profileId);
  Future<void> addTransaction(RewardTransaction transaction);
}
