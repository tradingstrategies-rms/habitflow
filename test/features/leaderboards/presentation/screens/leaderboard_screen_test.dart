import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/presentation/providers/leaderboard_providers.dart';
import 'package:habitflow/features/leaderboards/presentation/screens/leaderboard_screen.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  testWidgets('LeaderboardScreen shows entries', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final leaderboard = Leaderboard(
      id: 'l1',
      type: LeaderboardType.family,
      period: LeaderboardPeriod.weekly,
      entries: const [
        LeaderboardEntry(
          profileId: 'p1',
          displayName: 'User 1',
          score: 100,
          rank: 1,
          period: LeaderboardPeriod.weekly,
        ),
      ],
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
            LeaderboardPeriod.weekly,
            null,
          )).overrideWith((ref) => Future.value(leaderboard)),
          // We need to override others too for TabBarView
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.monthly,
            null,
          )).overrideWith((ref) => Future.value(null)),
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.allTime,
            null,
          )).overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(
          home: LeaderboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('User 1'), findsNWidgets(2));
    expect(find.text('100'), findsAtLeast(1));
  });
}
