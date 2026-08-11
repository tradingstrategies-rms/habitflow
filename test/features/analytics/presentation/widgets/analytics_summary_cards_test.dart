import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/presentation/widgets/analytics_summary_cards.dart';

void main() {
  group('AnalyticsSummaryCards', () {
    testWidgets('renders all metric cards with correct values', (tester) async {
      final metrics = AnalyticsMetrics(
        habitId: 'h1',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 31),
        completedCount: 20,
        activeDays: 15,
        activityRate: 0.5,
        longestStreak: 5,
        averageGapDays: 1.5,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalyticsSummaryCards(metrics: metrics)),
      ));

      expect(find.text('50.0%'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
      expect(find.text('1.5 days'), findsOneWidget);
      
      expect(find.text('Activity Rate'), findsOneWidget);
      expect(find.text('Active Days'), findsOneWidget);
      expect(find.text('Longest Streak'), findsOneWidget);
      expect(find.text('Avg. Gap'), findsOneWidget);
    });
  });
}
