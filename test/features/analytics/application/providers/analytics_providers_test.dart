import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/domain/entities/habit_completion.dart';

void main() {
  group('Analytics Providers', () {
    test('habitDailyAnalyticsProvider returns correct number of days', () async {
      final container = ProviderContainer(
        overrides: [
          allHabitCompletionsProvider.overrideWith((ref) => Stream.value([
            HabitCompletion(
              id: 'c1',
              habitId: 'h1',
              completionDate: DateTime.now(),
              completed: true,
              completedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
          ])),
        ],
      );

      final now = DateTime.now();
      final end = DateTime(now.year, now.month, now.day);
      final start = end.subtract(const Duration(days: 6));

      // Wait for the stream to emit
      await container.read(allHabitCompletionsProvider.future);

      final metrics = container.read(habitDailyAnalyticsProvider(('h1', start, end)));
      
      expect(metrics.length, 7);
    });

    test('analyticsPeriodProvider defaults to 30 days', () {
      final container = ProviderContainer();
      expect(container.read(analyticsPeriodProvider), const Duration(days: 30));
    });

    test('selectedAnalyticsHabitIdProvider defaults to null', () {
      final container = ProviderContainer();
      expect(container.read(selectedAnalyticsHabitIdProvider), null);
    });
  });
}
