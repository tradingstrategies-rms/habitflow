import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/analytics/presentation/widgets/analytics_trend_section.dart';

void main() {
  group('AnalyticsTrendSection', () {
    testWidgets('renders improving trend correctly', (tester) async {
      final baseline = AnalyticsMetrics(
        habitId: 'h1',
        startDate: DateTime(2023, 1, 1),
        endDate: DateTime(2023, 1, 15),
        completedCount: 5,
        activeDays: 5,
        activityRate: 0.33,
        longestStreak: 2,
        averageGapDays: 2.0,
      );
      final recent = AnalyticsMetrics(
        habitId: 'h1',
        startDate: DateTime(2023, 1, 16),
        endDate: DateTime(2023, 1, 31),
        completedCount: 10,
        activeDays: 10,
        activityRate: 0.66,
        longestStreak: 5,
        averageGapDays: 1.0,
      );
      final trend = AnalyticsTrend(
        direction: AnalyticsTrendDirection.improving,
        recent: recent,
        baseline: baseline,
        delta: 0.33,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AnalyticsTrendSection(trend: trend)),
      ));

      expect(find.text('Improving'), findsOneWidget);
      expect(find.text('33.0%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);
    });
  });
}
