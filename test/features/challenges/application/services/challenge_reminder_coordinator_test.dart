import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/challenges/application/services/challenge_reminder_coordinator.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge.dart';
import 'package:habitflow/features/challenges/domain/entities/challenge_progress.dart';
import 'package:habitflow/features/challenges/presentation/providers/challenge_providers.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_type.dart';
import 'package:habitflow/features/challenges/domain/enums/challenge_difficulty.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationOrchestrator extends Mock implements NotificationOrchestrator {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFamilyRepository extends Mock implements FamilyRepository {}

class MockActiveProfileSessionNotifier extends ActiveProfileSessionNotifier {
  MockActiveProfileSessionNotifier(super.repository, {ActiveProfileSession? initialState}) {
    state = initialState;
  }
}

void main() {
  late MockNotificationOrchestrator mockOrchestrator;
  late MockSharedPreferences mockPrefs;
  late MockFamilyRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(const NotificationPayload(
      id: '',
      title: '',
      body: '',
      type: NotificationType.challengeReminder,
    ));
  });

  setUp(() {
    mockOrchestrator = MockNotificationOrchestrator();
    mockPrefs = MockSharedPreferences();
    mockRepo = MockFamilyRepository();

    when(() => mockOrchestrator.notify(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
  });

  final now = DateTime.now();
  const profileId = 'p1';
  final session = ActiveProfileSession(profileId: profileId, startedAt: now, pinVerified: true);

  final challengeStartingSoon = Challenge(
    id: 'c1',
    title: 'Starting Soon Challenge',
    description: 'Desc',
    type: ChallengeType.daily,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 10,
    unit: 'points',
    pointReward: 10,
    xpReward: 10,
    startDate: now.add(const Duration(hours: 12)),
    endDate: now.add(const Duration(days: 7)),
  );

  final challengeEndingSoon = Challenge(
    id: 'c2',
    title: 'Ending Soon Challenge',
    description: 'Desc',
    type: ChallengeType.daily,
    difficulty: ChallengeDifficulty.easy,
    targetValue: 10,
    unit: 'points',
    pointReward: 10,
    xpReward: 10,
    startDate: now.subtract(const Duration(days: 6)),
    endDate: now.add(const Duration(hours: 12)),
  );

  group('ChallengeReminderCoordinator', () {
    test('notifies when challenge is starting soon', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: session)),
        ],
      );

      final coordinator = container.read(challengeReminderCoordinatorProvider);
      
      coordinator.evaluate(profileId, [challengeStartingSoon], []);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
        return p.id.contains('startingSoon');
      })))).called(1);
    });

    test('notifies when challenge is ending soon and incomplete', () async {
       final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: session)),
        ],
      );

      final coordinator = container.read(challengeReminderCoordinatorProvider);

      final progress = ChallengeProgress(
        challengeId: 'c2',
        profileId: profileId,
        currentValue: 5,
        isCompleted: false,
        lastUpdatedAt: now.subtract(const Duration(hours: 1)),
        periodStartDate: challengeEndingSoon.startDate,
      );

      coordinator.evaluate(profileId, [challengeEndingSoon], [progress]);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
        return p.id.contains('endingSoon');
      })))).called(1);
    });

    test('deduplicates notifications', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: session)),
        ],
      );

      final coordinator = container.read(challengeReminderCoordinatorProvider);

      coordinator.evaluate(profileId, [challengeStartingSoon], []);
      coordinator.evaluate(profileId, [challengeStartingSoon], []);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any())).called(1);
    });

    test('resets deduplication on profile switch', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo)),
        ],
      );

      final sessionNotifier = container.read(activeProfileSessionProvider.notifier) as MockActiveProfileSessionNotifier;
      sessionNotifier.state = session;
      await Future.delayed(Duration.zero);
      
      final coordinator1 = container.read(challengeReminderCoordinatorProvider);
      coordinator1.evaluate('p1', [challengeStartingSoon], []);
      await Future.delayed(const Duration(milliseconds: 20));
      verify(() => mockOrchestrator.notify(any())).called(1);
      clearInteractions(mockOrchestrator);

      // Switch to Profile 2
      sessionNotifier.state = ActiveProfileSession(profileId: 'p2', startedAt: now, pinVerified: true);
      await Future.delayed(Duration.zero);
      
      final coordinator2 = container.read(challengeReminderCoordinatorProvider);
      coordinator2.evaluate('p2', [challengeStartingSoon], []);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any())).called(1);
    });
  });
}
