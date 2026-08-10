import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/presentation/providers/leaderboard_providers.dart';
import 'package:habitflow/features/leaderboards/presentation/widgets/leaderboard_preview_card.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  testWidgets('LeaderboardPreviewCard shows rank info', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    const entry = LeaderboardEntry(
      profileId: 'p1',
      displayName: 'User 1',
      score: 500,
      rank: 3,
      period: LeaderboardPeriod.allTime,
    );

    final leaderboard = Leaderboard(
      id: 'l1',
      type: LeaderboardType.family,
      period: LeaderboardPeriod.allTime,
      entries: const [entry],
      lastUpdatedAt: DateTime.now(),
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockRepo),
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.allTime,
            null,
          )).overrideWith((ref) => Future.value(leaderboard)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: LeaderboardPreviewCard(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('You are ranked #3'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
  });
}
