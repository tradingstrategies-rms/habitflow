import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart' as family_p;
import 'package:habitflow/features/leaderboards/application/services/leaderboard_notification_coordinator.dart';
import 'package:habitflow/features/leaderboards/domain/entities/leaderboard_entry.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_period.dart';
import 'package:habitflow/features/leaderboards/domain/enums/leaderboard_type.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationOrchestrator extends Mock implements NotificationOrchestrator {}
class MockFamilyRepository extends Mock implements FamilyRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockActiveProfileSessionNotifier extends ActiveProfileSessionNotifier {
  MockActiveProfileSessionNotifier(super.repository, {ActiveProfileSession? initialState}) {
    state = initialState;
  }
}

class MockFamilyNotifier extends family_p.FamilyNotifier {
  MockFamilyNotifier(super.repository, super.ref, {family_p.FamilyState initialState = const family_p.FamilyState()}) {
    state = initialState;
  }

  @override
  Future<void> loadFamily() async {}
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
      type: NotificationType.leaderboard,
    ));
  });

  setUp(() {
    mockOrchestrator = MockNotificationOrchestrator();
    mockPrefs = MockSharedPreferences();
    mockRepo = MockFamilyRepository();

    when(() => mockOrchestrator.notify(any())).thenAnswer((_) async => true);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
    
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.getString(any())).thenReturn(null);
  });

  final familyCircle = FamilyCircle(id: 'f1', name: 'Family', ownerProfileId: 'p1', createdAt: DateTime.now());
  final activeSession = ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true);

  group('LeaderboardNotificationCoordinator', () {
    test('notifies when entering leaderboard', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(circle: familyCircle)
          )),
        ],
      );

      final coordinator = container.read(leaderboardNotificationCoordinatorProvider);

      const entry = LeaderboardEntry(
        profileId: 'p1',
        displayName: 'User 1',
        score: 1000,
        rank: 15,
        period: LeaderboardPeriod.weekly,
      );

      coordinator.processTransition(LeaderboardType.family, LeaderboardPeriod.weekly, 'p1', entry, familyCircle.id);
      await Future.delayed(Duration.zero);

      verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
        return p.title == "You're on the board!";
      })))).called(1);
    });

    test('notifies when rank improves by 2 or more', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(circle: familyCircle)
          )),
        ],
      );

      final coordinator = container.read(leaderboardNotificationCoordinatorProvider);

      // Baseline: Rank 10
      coordinator.processTransition(LeaderboardType.family, LeaderboardPeriod.weekly, 'p1', 
        const LeaderboardEntry(profileId: 'p1', displayName: 'U1', score: 100, rank: 10, period: LeaderboardPeriod.weekly), familyCircle.id);
      await Future.delayed(Duration.zero);
      clearInteractions(mockOrchestrator);

      // Transition: Rank 10 -> 8
      coordinator.processTransition(LeaderboardType.family, LeaderboardPeriod.weekly, 'p1', 
        const LeaderboardEntry(profileId: 'p1', displayName: 'U1', score: 120, rank: 8, period: LeaderboardPeriod.weekly), familyCircle.id);
      await Future.delayed(Duration.zero);

      verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
        return p.title == "You're climbing!";
      })))).called(1);
    });

    test('resets tracking on profile switch', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo)),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(circle: familyCircle)
          )),
        ],
      );

      final sessionNotifier = container.read(activeProfileSessionProvider.notifier) as MockActiveProfileSessionNotifier;
      sessionNotifier.state = activeSession;
      await Future.delayed(Duration.zero);
      
      final coordinator = container.read(leaderboardNotificationCoordinatorProvider);

      coordinator.processTransition(LeaderboardType.family, LeaderboardPeriod.weekly, 'p1', 
        const LeaderboardEntry(profileId: 'p1', displayName: 'U1', score: 100, rank: 5, period: LeaderboardPeriod.weekly), familyCircle.id);
      await Future.delayed(Duration.zero);
      verify(() => mockOrchestrator.notify(any())).called(2); // Entered + Top 5
      clearInteractions(mockOrchestrator);

      // Switch to Profile 2
      sessionNotifier.state = ActiveProfileSession(profileId: 'p2', startedAt: DateTime.now(), pinVerified: true);
      await Future.delayed(Duration.zero);
      
      final coordinator2 = container.read(leaderboardNotificationCoordinatorProvider);
      
      // Re-trigger for Profile 1
      coordinator2.processTransition(LeaderboardType.family, LeaderboardPeriod.weekly, 'p1',
        const LeaderboardEntry(profileId: 'p1', displayName: 'U1', score: 100, rank: 5, period: LeaderboardPeriod.weekly), familyCircle.id);
      await Future.delayed(Duration.zero);

      verify(() => mockOrchestrator.notify(any())).called(2);
    });
  });
}
