import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_recommendation.dart';
import 'package:habitflow/features/intelligence/presentation/screens/intelligence_dashboard_screen.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';

class MockActiveProfileNotifier extends ActiveProfileNotifier {
  MockActiveProfileNotifier(super.ref, [FamilyProfile? state]) {
    this.state = state;
  }
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockTelemetryService extends Mock implements PremiumTelemetryService {}

void main() {
  setUpAll(() {
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.subscriptionScreenViewed,
      timestamp: DateTime.now(),
    ));
  });

  const premiumSubscription = Subscription(
    id: 'premium',
    status: SubscriptionStatus.premium,
  );

  group('IntelligenceDashboardScreen', () {
    late MockSharedPreferences mockPrefs;
    late MockTelemetryService mockTelemetry;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      when(() => mockPrefs.getString(any())).thenReturn(null);
      mockTelemetry = MockTelemetryService();
      when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});
      when(() => mockTelemetry.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());
    });

    testWidgets('renders empty state when no data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
            premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
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
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
            premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
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
