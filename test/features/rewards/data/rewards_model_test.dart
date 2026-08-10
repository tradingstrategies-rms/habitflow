import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/rewards/data/models/reward_account_model.dart';
import 'package:habitflow/features/rewards/data/models/reward_transaction_model.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';

void main() {
  group('RewardAccountModel', () {
    final now = DateTime.now();
    final account = RewardAccount(
      profileId: 'p1',
      points: 100,
      experience: 500,
      level: 5,
      lifetimeEarnings: 1000,
      lastUpdatedAt: now,
    );

    test('fromEntity creates correct model', () {
      final model = RewardAccountModel.fromEntity(account);
      expect(model.profileId, account.profileId);
      expect(model.points, account.points);
      expect(model.level, account.level);
    });

    test('toEntity creates correct entity', () {
      final model = RewardAccountModel.fromEntity(account);
      final entity = model.toEntity();
      expect(entity, account);
    });

    test('json serialization works', () {
      final model = RewardAccountModel.fromEntity(account);
      final json = model.toJson();
      final fromJson = RewardAccountModel.fromJson(json);
      expect(fromJson.profileId, account.profileId);
      expect(fromJson.points, account.points);
    });
  });

  group('RewardTransactionModel', () {
    final now = DateTime.now();
    final transaction = RewardTransaction(
      id: 't1',
      profileId: 'p1',
      amount: 10,
      type: RewardType.points,
      source: RewardSource.habitCompletion,
      description: 'Test',
      createdAt: now,
    );

    test('fromEntity creates correct model', () {
      final model = RewardTransactionModel.fromEntity(transaction);
      expect(model.id, transaction.id);
      expect(model.amount, transaction.amount);
    });

    test('json serialization works', () {
      final model = RewardTransactionModel.fromEntity(transaction);
      final json = model.toJson();
      final fromJson = RewardTransactionModel.fromJson(json);
      expect(fromJson.id, transaction.id);
      expect(fromJson.source, transaction.source);
    });
  });
}
