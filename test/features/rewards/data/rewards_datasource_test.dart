import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/rewards/data/datasources/rewards_local_datasource.dart';
import 'package:habitflow/features/rewards/data/models/reward_account_model.dart';
import 'package:habitflow/features/rewards/data/models/reward_transaction_model.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';

void main() {
  late RewardsLocalDatasourceImpl datasource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = RewardsLocalDatasourceImpl(prefs);
  });

  group('RewardsLocalDatasource', () {
    final now = DateTime.now();
    final account = RewardAccountModel(
      profileId: 'p1',
      points: 100,
      experience: 500,
      level: 5,
      lifetimeEarnings: 1000,
      lastUpdatedAt: now,
    );

    test('saveAccount and getAccount works', () async {
      await datasource.saveAccount(account);
      final retrieved = await datasource.getAccount('p1');
      expect(retrieved?.points, 100);
      expect(retrieved?.profileId, 'p1');
    });

    test('addTransaction and getTransactions works', () async {
      final transaction = RewardTransactionModel(
        id: 't1',
        profileId: 'p1',
        amount: 10,
        type: RewardType.points,
        source: RewardSource.habitCompletion,
        description: 'Test',
        createdAt: now,
      );

      await datasource.addTransaction(transaction);
      final list = await datasource.getTransactions('p1');
      expect(list.length, 1);
      expect(list.first.id, 't1');
    });

    test('profile isolation works', () async {
      await datasource.saveAccount(account);
      final retrieved = await datasource.getAccount('p2');
      expect(retrieved, isNull);
    });
  });
}
