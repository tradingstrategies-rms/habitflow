import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/domain/entities/daily_analytics_metric.dart';
import 'package:habitflow/features/analytics/presentation/widgets/habit_heatmap.dart';

void main() {
  group('HabitHeatmap', () {
    testWidgets('renders empty state when no metrics', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: HabitHeatmap(metrics: [])),
      ));

      expect(find.text('No data available'), findsOneWidget);
    });

    testWidgets('renders heatmap grid when metrics provided', (tester) async {
      final now = DateTime.now();
      final metrics = List.generate(30, (i) => DailyAnalyticsMetric(
        date: now.subtract(Duration(days: 29 - i)),
        isActive: i % 2 == 0,
        completionCount: i % 3,
      ));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: HabitHeatmap(metrics: metrics)),
      ));

      expect(find.text('Activity Map'), findsOneWidget);
      // Tooltip is inside the day boxes
      expect(find.byType(Tooltip), findsNWidgets(30));
    });

    testWidgets('shows legend', (tester) async {
      final now = DateTime.now();
      final metrics = [DailyAnalyticsMetric(date: now, isActive: true, completionCount: 1)];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: HabitHeatmap(metrics: metrics)),
      ));

      expect(find.text('Less'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });
  });
}
