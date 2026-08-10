import '../../domain/entities/reward_account.dart';
import '../../domain/entities/reward_transaction.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../datasources/rewards_local_datasource.dart';
import '../models/reward_account_model.dart';
import '../models/reward_transaction_model.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  final RewardsLocalDatasource _datasource;

  RewardsRepositoryImpl(this._datasource);

  @override
  Future<RewardAccount?> getAccount(String profileId) async {
    final model = await _datasource.getAccount(profileId);
    return model?.toEntity();
  }

  @override
  Future<void> saveAccount(RewardAccount account) async {
    await _datasource.saveAccount(RewardAccountModel.fromEntity(account));
  }

  @override
  Future<List<RewardTransaction>> getTransactions(String profileId) async {
    final models = await _datasource.getTransactions(profileId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addTransaction(RewardTransaction transaction) async {
    await _datasource.addTransaction(RewardTransactionModel.fromEntity(transaction));
  }
}
