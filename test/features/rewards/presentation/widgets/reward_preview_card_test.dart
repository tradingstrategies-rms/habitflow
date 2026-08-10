import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/presentation/providers/reward_account_provider.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_preview_card.dart';

import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockActiveProfileSessionNotifier extends ActiveProfileSessionNotifier {
  MockActiveProfileSessionNotifier(ActiveProfileSession? session) : super(MockFamilyRepository()) {
    state = session;
  }
}

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  testWidgets('RewardPreviewCard shows loading then data', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final account = RewardAccount(
      profileId: 'p1',
      points: 2450,
      experience: 650,
      level: 8,
      lifetimeEarnings: 5000,
      lastUpdatedAt: DateTime.now(),
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockRepo),
          rewardAccountProvider('p1').overrideWith((ref) => Future.delayed(const Duration(milliseconds: 100), () => account)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: RewardPreviewCard(),
          ),
        ),
      ),
    );

    // Initial load state
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for future to complete
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('2450 Stars'), findsOneWidget);
    expect(find.text('Level 8 - Consistency Builder'), findsOneWidget);
  });
}
