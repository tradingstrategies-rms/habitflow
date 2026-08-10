import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/rewards/domain/entities/reward_account.dart';
import 'package:habitflow/features/rewards/presentation/widgets/reward_balance_card.dart';

void main() {
  testWidgets('RewardBalanceCard displays account info correctly', (tester) async {
    final account = RewardAccount(
      profileId: 'p1',
      points: 2450,
      experience: 650,
      level: 8,
      lifetimeEarnings: 5000,
      lastUpdatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardBalanceCard(
            account: account,
            levelProgress: 0.65,
            nextLevelName: 'Master',
          ),
        ),
      ),
    );

    expect(find.text('2,450'), findsOneWidget);
    expect(find.text('Next Level: Master'), findsOneWidget);
    expect(find.text('650 / 1000 XP'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
