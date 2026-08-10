import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/reward_store/data/repositories/reward_store_repository_impl.dart';
import 'package:habitflow/features/reward_store/data/datasources/reward_store_local_datasource.dart';
import 'package:habitflow/features/reward_store/data/models/reward_item_model.dart';
import 'package:habitflow/features/reward_store/data/models/reward_redemption_model.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';

class MockRewardStoreLocalDatasource extends Mock implements RewardStoreLocalDatasource {}

void main() {
  late RewardStoreRepositoryImpl repository;
  late MockRewardStoreLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockRewardStoreLocalDatasource();
    repository = RewardStoreRepositoryImpl(mockDatasource);
    
    registerFallbackValue(const RewardItemModel(
      id: '',
      title: '',
      description: '',
      pointsCost: 0,
      category: RewardCategory.other,
    ));

    registerFallbackValue(RewardRedemptionModel(
      id: '',
      profileId: '',
      rewardItemId: '',
      pointsSpent: 0,
      status: RedemptionStatus.pending,
      createdAt: DateTime.now(),
    ));
  });

  group('RewardStoreRepositoryImpl', () {
    test('getAvailableItems filters correctly', () async {
      final items = [
        const RewardItemModel(id: '1', title: 'I1', description: 'D1', pointsCost: 10, category: RewardCategory.digital, isAvailable: true),
        const RewardItemModel(id: '2', title: 'I2', description: 'D2', pointsCost: 20, category: RewardCategory.other, isAvailable: false),
      ];
      
      when(() => mockDatasource.getItems()).thenAnswer((_) async => items);

      final result = await repository.getAvailableItems();
      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test('saveRedemption calls datasource', () async {
      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'p1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.approved,
        createdAt: DateTime.now(),
      );
      
      when(() => mockDatasource.saveRedemption(any())).thenAnswer((_) async {});

      await repository.saveRedemption(redemption);
      verify(() => mockDatasource.saveRedemption(any())).called(1);
    });
  });
}
