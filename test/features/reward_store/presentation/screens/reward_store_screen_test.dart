import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/presentation/providers/reward_store_providers.dart';
import 'package:habitflow/features/reward_store/presentation/screens/reward_store_screen.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  const items = [
    RewardItem(id: '1', title: 'I1', description: 'D1', pointsCost: 10, category: RewardCategory.digital),
    RewardItem(id: '2', title: 'I2', description: 'D2', pointsCost: 20, category: RewardCategory.physical),
  ];

  testWidgets('RewardStoreScreen shows items and balance', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final account = RewardAccount(
      profileId: 'p1',
      points: 100,
      experience: 0,
      level: 1,
      lifetimeEarnings: 100,
      lastUpdatedAt: DateTime.now(),
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockRepo),
          rewardCatalogProvider.overrideWith((ref) => Future.value(items)),
          rewardAccountProvider('p1').overrideWith((ref) => Future.value(account)),
        ],
        child: const MaterialApp(
          home: RewardStoreScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('100'), findsOneWidget); // Balance
    expect(find.text('I1'), findsOneWidget);
    expect(find.text('I2'), findsOneWidget);
  });
}
