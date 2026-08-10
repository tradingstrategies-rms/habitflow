import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:habitflow/features/rewards/data/datasources/rewards_local_datasource.dart';
import 'package:habitflow/features/rewards/data/models/reward_account_model.dart';
import 'package:habitflow/features/rewards/data/models/reward_transaction_model.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';

class MockRewardsLocalDatasource extends Mock implements RewardsLocalDatasource {}

void main() {
  late RewardsRepositoryImpl repository;
  late MockRewardsLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockRewardsLocalDatasource();
    repository = RewardsRepositoryImpl(mockDatasource);
    registerFallbackValue(RewardAccountModel(
      profileId: '',
      points: 0,
      experience: 0,
      level: 1,
      lifetimeEarnings: 0,
      lastUpdatedAt: DateTime.now(),
    ));
    registerFallbackValue(RewardTransactionModel(
      id: '',
      profileId: '',
      amount: 0,
      type: RewardType.points,
      source: RewardSource.manualAdjustment,
      description: '',
      createdAt: DateTime.now(),
    ));
  });

  group('RewardsRepositoryImpl', () {
    final now = DateTime.now();
    final account = RewardAccount(
      profileId: 'p1',
      points: 100,
      experience: 500,
      level: 5,
      lifetimeEarnings: 1000,
      lastUpdatedAt: now,
    );

    test('getAccount delegates to datasource and returns entity', () async {
      when(() => mockDatasource.getAccount('p1'))
          .thenAnswer((_) async => RewardAccountModel.fromEntity(account));

      final result = await repository.getAccount('p1');

      expect(result, account);
      verify(() => mockDatasource.getAccount('p1')).called(1);
    });

    test('saveAccount delegates to datasource', () async {
      when(() => mockDatasource.saveAccount(any())).thenAnswer((_) async {});

      await repository.saveAccount(account);

      verify(() => mockDatasource.saveAccount(any())).called(1);
    });
  });
}
