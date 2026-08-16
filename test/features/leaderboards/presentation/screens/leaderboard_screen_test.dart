import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:habitflow/features/leaderboards/presentation/providers/leaderboard_providers.dart';
import 'package:habitflow/features/leaderboards/presentation/screens/leaderboard_screen.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
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

class MockFamilyRepository extends Mock implements FamilyRepository {}
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

  testWidgets('LeaderboardScreen shows entries', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final leaderboard = Leaderboard(
      id: 'l1',
      type: LeaderboardType.family,
      period: LeaderboardPeriod.weekly,
      entries: const [
        LeaderboardEntry(
          profileId: 'p1',
          displayName: 'User 1',
          score: 100,
          rank: 1,
          period: LeaderboardPeriod.weekly,
        ),
      ],
      lastUpdatedAt: DateTime.now(),
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);

    final mockTelemetry = MockTelemetryService();
    when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});
    when(() => mockTelemetry.getMetrics()).thenAnswer((_) async => PremiumConversionMetrics.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
          familyRepositoryProvider.overrideWithValue(mockRepo),
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.weekly,
            null,
          )).overrideWith((ref) => Future.value(leaderboard)),
          // We need to override others too for TabBarView
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.monthly,
            null,
          )).overrideWith((ref) => Future.value(null)),
          currentLeaderboardProvider((
            LeaderboardType.family,
            LeaderboardPeriod.allTime,
            null,
          )).overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(
          home: LeaderboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('User 1'), findsNWidgets(2));
    expect(find.text('100'), findsAtLeast(1));
  });
}
