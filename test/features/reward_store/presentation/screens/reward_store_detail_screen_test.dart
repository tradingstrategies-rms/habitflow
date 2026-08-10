import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:habitflow/features/reward_store/presentation/screens/reward_store_detail_screen.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

class MockActiveProfileSessionNotifier extends ActiveProfileSessionNotifier {
  MockActiveProfileSessionNotifier(ActiveProfileSession? session, FamilyRepository repo) : super(repo) {
    state = session;
  }
}

void main() {
  const item = RewardItem(
    id: 'i1',
    title: 'Reward Title',
    description: 'Reward Description',
    pointsCost: 50,
    category: RewardCategory.other,
  );

  final session = ActiveProfileSession(
    profileId: 'p1',
    pinVerified: true,
    startedAt: DateTime.now(),
  );

  testWidgets('RewardStoreDetailScreen shows Not Enough Stars when points are low', (tester) async {
    final poorAccount = RewardAccount(
      profileId: 'p1', points: 10, experience: 0, level: 1, lifetimeEarnings: 10, lastUpdatedAt: DateTime.now()
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(session, mockRepo)),
          rewardAccountProvider('p1').overrideWith((ref) => Future.value(poorAccount)),
        ],
        child: const MaterialApp(
          home: RewardStoreDetailScreen(item: item),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Not Enough Stars'), findsOneWidget);
  });

  testWidgets('RewardStoreDetailScreen shows Redeem Reward when points are enough', (tester) async {
    final richAccount = RewardAccount(
      profileId: 'p1', points: 100, experience: 0, level: 1, lifetimeEarnings: 100, lastUpdatedAt: DateTime.now()
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(session, mockRepo)),
          rewardAccountProvider('p1').overrideWith((ref) => Future.value(richAccount)),
        ],
        child: const MaterialApp(
          home: RewardStoreDetailScreen(item: item),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Redeem Reward'), findsOneWidget);
  });
}
