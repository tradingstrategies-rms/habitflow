import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_recommendation.dart';
import 'package:habitflow/features/intelligence/presentation/screens/intelligence_dashboard_screen.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';

class MockActiveProfileNotifier extends ActiveProfileNotifier {
  MockActiveProfileNotifier(super.ref, [FamilyProfile? state]) {
    this.state = state;
  }
}

void main() {
  group('IntelligenceDashboardScreen', () {
    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceDashboardProvider.overrideWith((ref) => Future.value(null)),
            activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref)),
          ],
          child: const MaterialApp(home: IntelligenceDashboardScreen()),
        ),
      );

      await tester.pump(); // Start loading
      await tester.pump(); // Finish loading

      expect(find.text('No Data Yet'), findsOneWidget);
    });

    testWidgets('renders insights and recommendations', (tester) async {
      final summary = IntelligenceDashboardSummary(
        priorityInsight: HabitInsight(
          id: 'i1',
          habitId: 'h1',
          category: InsightCategory.trend,
          severity: InsightSeverity.high,
          title: 'Fading Habit',
          summary: 'Your exercise habit is fading.',
          explanation: 'Longer explanation here.',
          supportingPatterns: [],
          generatedAt: DateTime.now(),
        ),
        topRecommendation: HabitRecommendation(
          id: 'r1',
          habitId: 'h1',
          type: RecommendationType.goalAdjustment,
          priority: RecommendationPriority.high,
          title: 'Emergency Reset',
          summary: 'Lower the barrier.',
          reason: 'Decline detected.',
          suggestedAction: 'Try 1 minute.',
          supportingInsights: [],
          generatedAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            intelligenceDashboardProvider.overrideWith((ref) => Future.value(summary)),
            activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref)),
          ],
          child: const MaterialApp(home: IntelligenceDashboardScreen()),
        ),
      );

      await tester.pump(); // Start loading
      await tester.pump(); // Finish loading

      expect(find.text('Priority Insight'), findsOneWidget);
      expect(find.text('Fading Habit'), findsOneWidget);
      expect(find.text('Next Step'), findsOneWidget);
      expect(find.text('Suggested Action'), findsOneWidget); // Inside RecommendationCard
      expect(find.text('Emergency Reset'), findsOneWidget);
    });
  });
}
