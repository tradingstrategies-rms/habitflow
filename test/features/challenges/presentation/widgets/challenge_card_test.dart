import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/presentation/widgets/challenge_card.dart';

void main() {
  final challenge = Challenge(
    id: 'c1',
    title: 'Water Master',
    description: 'Drink 8 glasses of water daily for a week.',
    type: ChallengeType.daily,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 7,
    unit: 'days',
    pointReward: 50,
    xpReward: 200,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
  );

  testWidgets('ChallengeCard displays info correctly', (tester) async {
    final progress = ChallengeProgress(
      challengeId: 'c1',
      profileId: 'p1',
      currentValue: 3,
      lastUpdatedAt: DateTime.now(),
      periodStartDate: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChallengeCard(
              challenge: challenge,
              progress: progress,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Water Master'), findsOneWidget);
    expect(find.text('Drink 8 glasses of water daily for a week.'), findsOneWidget);
    expect(find.text('3 / 7 days'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    expect(find.text('+200 XP'), findsOneWidget);
    expect(find.text('EASY'), findsOneWidget);
  });

  testWidgets('ChallengeCard shows completed state', (tester) async {
    final progress = ChallengeProgress(
      challengeId: 'c1',
      profileId: 'p1',
      currentValue: 7,
      isCompleted: true,
      lastUpdatedAt: DateTime.now(),
      periodStartDate: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ChallengeCard(
              challenge: challenge,
              progress: progress,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });
}
