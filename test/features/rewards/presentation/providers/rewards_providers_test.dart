import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_transactions_provider.dart';
import 'package:habitflow/features/rewards/presentation/providers/rewards_repository_provider.dart';

class MockRewardsRepository extends Mock implements RewardsRepository {}

void main() {
  late MockRewardsRepository mockRepository;

  setUp(() {
    mockRepository = MockRewardsRepository();
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

  group('Rewards Providers', () {
    final now = DateTime.now();
    final account = RewardAccount(
      profileId: 'p1',
      points: 100,
      experience: 500,
      level: 5,
      lifetimeEarnings: 1000,
      lastUpdatedAt: now,
    );

    test('rewardAccountProvider fetches account correctly', () async {
      when(() => mockRepository.getAccount('p1')).thenAnswer((_) async => account);

      final container = createContainer();
      final result = await container.read(rewardAccountProvider('p1').future);

      expect(result, account);
      verify(() => mockRepository.getAccount('p1')).called(1);
    });

    test('rewardTransactionsProvider fetches transactions correctly', () async {
      when(() => mockRepository.getTransactions('p1')).thenAnswer((_) async => []);

      final container = createContainer();
      final result = await container.read(rewardTransactionsProvider('p1').future);

      expect(result, isEmpty);
      verify(() => mockRepository.getTransactions('p1')).called(1);
    });
  });
}
