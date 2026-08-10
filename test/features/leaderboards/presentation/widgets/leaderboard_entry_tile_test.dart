import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/presentation/widgets/leaderboard_entry_tile.dart';

void main() {
  testWidgets('LeaderboardEntryTile displays entry info', (tester) async {
    const entry = LeaderboardEntry(
      profileId: 'p1',
      displayName: 'Test User',
      score: 1250,
      rank: 2,
      period: LeaderboardPeriod.allTime,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LeaderboardEntryTile(entry: entry),
        ),
      ),
    );

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('1250'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
