import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenge_providers.dart';
import 'package:habitflow/features/challenges/presentation/screens/completed_challenges_screen.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/subscription/application/providers/subscription_providers.dart';
import 'package:habitflow/features/billing/domain/entities/premium_event_type.dart';
import 'package:habitflow/features/billing/domain/entities/premium_telemetry_event.dart';
import 'package:habitflow/features/billing/application/providers/telemetry_providers.dart';
import 'package:habitflow/features/billing/domain/repositories/premium_telemetry_service.dart';
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

  final challenge = Challenge(
    id: 'c1',
    title: 'Water Master',
    description: 'Drink 8 glasses of water daily for a week.',
    type: ChallengeType.daily,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 7,
    unit: 'days',
    pointReward: 50,
    xpReward: 200,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
  );

  testWidgets('CompletedChallengesScreen shows empty state', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);

    final mockTelemetry = MockTelemetryService();
    when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
          familyRepositoryProvider.overrideWithValue(mockRepo),
          completedChallengesProvider('p1').overrideWith((ref) => []),
          profileProgressProvider('p1').overrideWith((ref) => []),
        ],
        child: const MaterialApp(
          home: CompletedChallengesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No Completed Challenges'), findsOneWidget);
  });

  testWidgets('CompletedChallengesScreen shows completed challenges', (tester) async {
    final session = ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: DateTime.now(),
    );

    final progress = [
      ChallengeProgress(
        challengeId: 'c1',
        profileId: 'p1',
        currentValue: 7,
        isCompleted: true,
        lastUpdatedAt: DateTime.now(),
        periodStartDate: DateTime.now(),
      )
    ];

    final mockRepo = MockFamilyRepository();
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => session);

    final mockPrefs = MockSharedPreferences();
    when(() => mockPrefs.getString(any())).thenReturn(null);

    final mockTelemetry = MockTelemetryService();
    when(() => mockTelemetry.recordEvent(any())).thenAnswer((_) async => {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          premiumTelemetryServiceProvider.overrideWithValue(mockTelemetry),
          premiumServiceProvider.overrideWithValue(PremiumService(premiumSubscription)),
          familyRepositoryProvider.overrideWithValue(mockRepo),
          completedChallengesProvider('p1').overrideWith((ref) => [challenge]),
          profileProgressProvider('p1').overrideWith((ref) => Future.value(progress)),
        ],
        child: const MaterialApp(
          home: CompletedChallengesScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Water Master'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
