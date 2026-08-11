import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/analytics/domain/entities/family_productivity_score.dart';
import 'package:habitflow/features/family/presentation/widgets/family_productivity_score_card.dart';

void main() {
  group('FamilyProductivityScoreCard', () {
    testWidgets('renders score and trend correctly', (tester) async {
      final score = FamilyProductivityScore(
        familyId: 'f1',
        score: 85.0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        participatingProfileCount: 3,
        averageActivityRate: 0.85,
        trend: AnalyticsTrendDirection.improving,
        trendDelta: 10.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyProductivityScoreProvider(const Duration(days: 30))
                .overrideWithValue(AsyncValue.data(score)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FamilyProductivityScoreCard(),
            ),
          ),
        ),
      );

      expect(find.text('85'), findsOneWidget);
      expect(find.text('Family Productivity'), findsOneWidget);
      expect(find.text('Improving'), findsOneWidget);
      expect(find.text('3 Members active (30d)'), findsOneWidget);
    });

    testWidgets('renders child version correctly', (tester) async {
      final score = FamilyProductivityScore(
        familyId: 'f1',
        score: 90.0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        participatingProfileCount: 3,
        averageActivityRate: 0.9,
        trend: AnalyticsTrendDirection.stable,
        trendDelta: 0.0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyProductivityScoreProvider(const Duration(days: 30))
                .overrideWithValue(AsyncValue.data(score)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FamilyProductivityScoreCard(isChild: true),
            ),
          ),
        ),
      );

      expect(find.text('90'), findsOneWidget);
      expect(find.text('Our Family Progress'), findsOneWidget);
      expect(find.text('Keep it up, team!'), findsOneWidget);
      // Trend delta should be hidden for child
      expect(find.textContaining('pts vs prev.'), findsNothing);
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            familyProductivityScoreProvider(const Duration(days: 30))
                .overrideWithValue(const AsyncValue.loading()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FamilyProductivityScoreCard(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
