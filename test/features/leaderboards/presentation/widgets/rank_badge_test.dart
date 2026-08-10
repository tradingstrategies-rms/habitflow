import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/presentation/widgets/rank_badge.dart';

void main() {
  testWidgets('RankBadge displays number correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RankBadge(rank: 1),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('RankBadge displays higher rank correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RankBadge(rank: 10),
        ),
      ),
    );

    expect(find.text('10'), findsOneWidget);
  });
}
