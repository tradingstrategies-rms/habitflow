import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:habitflow/features/analytics/presentation/analytics_screen.dart';
import 'package:habitflow/features/challenges/presentation/screens/completed_challenges_screen.dart';
import 'package:habitflow/features/intelligence/presentation/screens/intelligence_dashboard_screen.dart';
import 'package:habitflow/features/leaderboards/presentation/screens/leaderboard_screen.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/subscription/application/services/premium_service.dart';
import 'package:habitflow/features/subscription/domain/entities/subscription.dart';
import 'package:habitflow/features/subscription/domain/enums/subscription_status.dart';
import 'package:habitflow/features/subscription/presentation/widgets/premium_feature_locked_view.dart';
import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/analytics/application/providers/analytics_providers.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:habitflow/features/analytics/domain/entities/analytics_trend.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/habits/domain/entities/habit.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_category.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_color.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_frequency.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_icon.dart';
import 'package:habitflow/features/habits/domain/value_objects/habit_priority.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_conversion_metrics.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenge_providers.dart';
import 'package:habitflow/core/theme/theme_controller.dart';

class MockRef extends Mock implements Ref {}
class MockTelemetryService extends Mock implements PremiumTelemetryService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeActiveProfileNotifier extends ActiveProfileNotifier {
  FakeActiveProfileNotifier(FamilyProfile? initial) : super(MockRef()) {
    state = initial;
  }
  @override
  void setActiveProfile(FamilyProfile profile) {}
}

class FakeActiveProfileSessionNotifier extends ActiveProfileSessionNotifier {
  FakeActiveProfileSessionNotifier(ActiveProfileSession? initial) : super(null as dynamic) {
    state = initial;
  }
}

void main() {
  late MockTelemetryService mockTelemetryService;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(MockRef());
    registerFallbackValue(PremiumTelemetryEvent(
      type: PremiumEventType.subscriptionScreenViewed,
      timestamp: DateTime.now(),
    ));
  });

  setUp(() {
    mockTelemetryService = MockTelemetryService();
    mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn([]);
    when(() => mockPrefs.setStringList(any(), any())).thenAnswer((_) async => true);
    when(() => mockTelemetryService.recordEvent(any())).thenAnswer((_) async => {});
    when(() => mockTelemetryService.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());
  });

  const freeSubscription = Subscription(
    id: 'free',
    status: SubscriptionStatus.free,
    entitlements: [],
  );
  const premiumSubscription = Subscription(
    id: 'premium',
    status: SubscriptionStatus.premium,
  );

  final testProfile = FamilyProfile(
    id: 'p1',
    familyId: 'f1',
    displayName: 'Test User',
    profileType: ProfileType.adult,
    role: FamilyRole.owner,
    requiresPin: false,
    createdAt: DateTime.now(),
  );

  final testHabit = Habit(
    id: 'h1',
    userId: 'u1',
    title: 'Habit 1',
    category: HabitCategory.health,
    icon: HabitIcon.running,
    color: HabitColor.blue,
    priority: HabitPriority.medium,
    frequency: HabitFrequency.daily,
    targetValue: 1.0,
    unit: 'times',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final dummyMetrics = AnalyticsMetrics(
    habitId: 'h1',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
    completedCount: 0,
    activeDays: 0,
    activityRate: 0,
    longestStreak: 0,
    averageGapDays: 0,
  );

  final dummyTrend = AnalyticsTrend(
    direction: AnalyticsTrendDirection.stable,
    recent: dummyMetrics,
    baseline: dummyMetrics,
    delta: 0,
  );

  group('Premium Feature Gating', () {
    testWidgets('IntelligenceDashboardScreen is locked for free users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
            premiumServiceProvider.overrideWithValue(PremiumService(freeSubscription)),
            intelligenceDashboardProvider.overrideWith((ref) => null),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(testProfile)),
          ],
          child: const MaterialApp(
            home: IntelligenceDashboardScreen(),
          ),
        ),
      );

      expect(find.byType(PremiumFeatureLockedView), findsOneWidget);
      expect(find.text('Advanced Intelligence'), findsOneWidget);
    });

    testWidgets('IntelligenceDashboardScreen is available for premium users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
            premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
            intelligenceDashboardProvider.overrideWith((ref) => null),
            activeProfileProvider.overrideWith((ref) => FakeActiveProfileNotifier(testProfile)),
          ],
          child: const MaterialApp(
            home: IntelligenceDashboardScreen(),
          ),
        ),
      );

      expect(find.byType(PremiumFeatureLockedView), findsNothing);
    });

    testWidgets('LeaderboardScreen is locked for free users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
            premiumServiceProvider.overrideWithValue(PremiumService(freeSubscription)),
            activeProfileSessionProvider.overrideWith((ref) => FakeActiveProfileSessionNotifier(null) as dynamic),
          ],
          child: const MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );

      expect(find.byType(PremiumFeatureLockedView), findsOneWidget);
      expect(find.text('Family Leaderboards'), findsOneWidget);
    });

    testWidgets('Analytics 90-day period is locked for free users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
            premiumServiceProvider.overrideWithValue(PremiumService(freeSubscription)),
            activeHabitsProvider.overrideWith((ref) => AsyncValue.data([testHabit])),
            analyticsPeriodProvider.overrideWith((ref) => const Duration(days: 90)),
            selectedAnalyticsHabitIdProvider.overrideWith((ref) => 'h1'),
            habitAnalyticsProvider.overrideWith((ref, arg) => dummyMetrics),
            habitDailyAnalyticsProvider.overrideWith((ref, arg) => []),
            habitAnalyticsTrendProvider.overrideWith((ref, arg) => dummyTrend),
          ],
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PremiumFeatureLockedView), findsOneWidget);
      expect(find.text('90-Day Analytics'), findsOneWidget);
    });

    testWidgets('CompletedChallengesScreen is locked for free users', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
            premiumTelemetryServiceProvider.overrideWithValue(mockTelemetryService),
            premiumServiceProvider.overrideWithValue(PremiumService(freeSubscription)),
            activeProfileSessionProvider.overrideWith((ref) => FakeActiveProfileSessionNotifier(null) as dynamic),
            completedChallengesProvider.overrideWith((ref, arg) => []),
            profileProgressProvider.overrideWith((ref, arg) => []),
          ],
          child: const MaterialApp(
            home: CompletedChallengesScreen(),
          ),
        ),
      );

      expect(find.byType(PremiumFeatureLockedView), findsOneWidget);
      expect(find.text('Challenge History'), findsOneWidget);
    });
  });
}
