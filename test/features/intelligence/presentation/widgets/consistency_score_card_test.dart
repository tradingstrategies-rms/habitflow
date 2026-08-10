import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_consistency_score.dart';
import 'package:habitflow/features/intelligence/presentation/widgets/consistency_score_card.dart';

void main() {
  testWidgets('ConsistencyScoreCard renders correctly', (WidgetTester tester) async {
    final score = HabitConsistencyScore(
      habitId: 'test-habit',
      overallScore: 84.0,
      completionScore: 87.0,
      streakScore: 92.0,
      stabilityScore: 78.0,
      recoveryScore: 81.0,
      calculatedAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConsistencyScoreCard(score: score),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Overall Wellness Score'), findsOneWidget);
    // Score should be 84 (initial/end value)
    expect(find.text('84'), findsOneWidget);
  });
}
