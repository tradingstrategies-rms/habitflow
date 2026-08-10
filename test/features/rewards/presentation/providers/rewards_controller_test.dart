import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_transaction.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_type.dart';
import 'package:habitflow/features/rewards/domain/enums/reward_source.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_controller_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';

class MockRewardsRepository extends Mock implements RewardsRepository {}

void main() {
  late MockRewardsRepository mockRepository;

  setUp(() {
    mockRepository = MockRewardsRepository();
    registerFallbackValue(RewardAccount(
      profileId: '',
      points: 0,
      experience: 0,
      level: 1,
      lifetimeEarnings: 0,
      lastUpdatedAt: DateTime.now(),
    ));
    registerFallbackValue(RewardTransaction(
      id: '',
      profileId: '',
      amount: 0,
      type: RewardType.points,
      source: RewardSource.manualAdjustment,
      description: '',
      createdAt: DateTime.now(),
    ));
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        rewardsRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('RewardsController', () {
    test('saveAccount delegates to repository', () async {
      when(() => mockRepository.saveAccount(any())).thenAnswer((_) async {});
      
      final container = createContainer();
      final controller = container.read(rewardsControllerProvider);
      
      final account = RewardAccount(
        profileId: 'p1',
        points: 10,
        experience: 0,
        level: 1,
        lifetimeEarnings: 10,
        lastUpdatedAt: DateTime.now(),
      );
      
      await controller.saveAccount(account);
      
      verify(() => mockRepository.saveAccount(account)).called(1);
    });

    test('addTransaction delegates to repository and updates account', () async {
      final account = RewardAccount(
        profileId: 'p1',
        points: 0,
        experience: 0,
        level: 1,
        lifetimeEarnings: 0,
        lastUpdatedAt: DateTime.now(),
      );

      when(() => mockRepository.getAccount('p1')).thenAnswer((_) async => account);
      when(() => mockRepository.addTransaction(any())).thenAnswer((_) async {});
      when(() => mockRepository.saveAccount(any())).thenAnswer((_) async {});
      
      final container = createContainer();
      final controller = container.read(rewardsControllerProvider);
      
      final transaction = RewardTransaction(
        id: 't1',
        profileId: 'p1',
        amount: 5,
        type: RewardType.points,
        source: RewardSource.manualAdjustment,
        description: 'Test',
        createdAt: DateTime.now(),
      );
      
      await controller.addTransaction(transaction);
      
      verify(() => mockRepository.addTransaction(transaction)).called(1);
      verify(() => mockRepository.saveAccount(any())).called(1);
    });
  });
}
