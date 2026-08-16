import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/core/notifications/domain/notification_priority.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/intelligence/application/providers/intelligence_providers.dart';
import 'package:habitflow/features/intelligence/application/services/intelligence_notification_coordinator.dart';
import 'package:habitflow/features/intelligence/domain/entities/habit_insight.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationOrchestrator extends Mock implements NotificationOrchestrator {}
class MockFamilyRepository extends Mock implements FamilyRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

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
      type: NotificationType.intelligence,
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

  final highSeverityFadingInsight = HabitInsight(
    id: 'i1',
    habitId: 'h1',
    category: InsightCategory.warning,
    severity: InsightSeverity.high,
    title: 'Fading Habit',
    summary: 'Your habit is fading.',
    explanation: 'Explanation',
    supportingPatterns: [],
    generatedAt: DateTime.now(),
  );

  final mediumSeverityImprovingInsight = HabitInsight(
    id: 'i2',
    habitId: 'h1',
    category: InsightCategory.trend,
    severity: InsightSeverity.medium,
    title: 'On the Rise',
    summary: 'Improving!',
    explanation: 'Explanation',
    supportingPatterns: [],
    generatedAt: DateTime.now(),
  );

  final activeSession = ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true);

  test('should trigger notification for high severity fading insight', () async {
    final summary = IntelligenceDashboardSummary(
      priorityInsight: highSeverityFadingInsight,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
      ],
    );

    final coordinator = container.read(intelligenceNotificationCoordinatorProvider);
    
    coordinator.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    verify(() => mockOrchestrator.notify(any())).called(1);
  });

  test('should deduplicate repeated notifications for the same insight', () async {
    final summary = IntelligenceDashboardSummary(
      priorityInsight: highSeverityFadingInsight,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
      ],
    );

    final coordinator = container.read(intelligenceNotificationCoordinatorProvider);

    coordinator.processSummary(summary, 'p1');
    coordinator.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    verify(() => mockOrchestrator.notify(any())).called(1);
  });

  test('should not notify for low severity stable insights', () async {
    final lowSeverityInsight = HabitInsight(
      id: 'i3',
      habitId: 'h1',
      category: InsightCategory.general,
      severity: InsightSeverity.low,
      title: 'Stable',
      summary: 'Stay consistent.',
      explanation: 'Explanation',
      supportingPatterns: [],
      generatedAt: DateTime.now(),
    );

    final summary = IntelligenceDashboardSummary(
      priorityInsight: lowSeverityInsight,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
      ],
    );

    final coordinator = container.read(intelligenceNotificationCoordinatorProvider);

    coordinator.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    verifyNever(() => mockOrchestrator.notify(any()));
  });

  test('should include correct payload details', () async {
    final summary = IntelligenceDashboardSummary(
      priorityInsight: highSeverityFadingInsight,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
      ],
    );

    final coordinator = container.read(intelligenceNotificationCoordinatorProvider);
    coordinator.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
      return p.type == NotificationType.intelligence &&
             p.recipientProfileId == 'p1' &&
             p.route == '/intelligence' &&
             p.priority == NotificationPriority.high;
    })))).called(1);
  });

  test('should notify for improving trends with medium severity', () async {
    final summary = IntelligenceDashboardSummary(
      otherInsights: [mediumSeverityImprovingInsight],
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: activeSession)),
      ],
    );

    final coordinator = container.read(intelligenceNotificationCoordinatorProvider);
    coordinator.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    verify(() => mockOrchestrator.notify(any(that: predicate<NotificationPayload>((p) {
      return p.title == 'On the Rise' && p.priority == NotificationPriority.normal;
    })))).called(1);
  });

  test('should produce different IDs for different profiles', () async {
    final summary = IntelligenceDashboardSummary(
      priorityInsight: highSeverityFadingInsight,
    );

    final orchestrator = MockNotificationOrchestrator();
    when(() => orchestrator.notify(any())).thenAnswer((_) async => true);
    
    // Profile 1
    final session1 = ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true);
    final container1 = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(orchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: session1)),
      ],
    );

    container1.read(intelligenceNotificationCoordinatorProvider).processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);

    // Profile 2
    final session2 = ActiveProfileSession(profileId: 'p2', startedAt: DateTime.now(), pinVerified: true);
    final container2 = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(orchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: session2)),
      ],
    );

    container2.read(intelligenceNotificationCoordinatorProvider).processSummary(summary, 'p2');
    await Future.delayed(Duration.zero);

    verify(() => orchestrator.notify(any(that: predicate<NotificationPayload>((p) => p.id.contains('p1'))))).called(1);
    verify(() => orchestrator.notify(any(that: predicate<NotificationPayload>((p) => p.id.contains('p2'))))).called(1);
  });

  test('should reset deduplication on profile switch', () async {
    final summary = IntelligenceDashboardSummary(
      priorityInsight: highSeverityFadingInsight,
    );

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
        activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo)),
      ],
    );

    final sessionNotifier = container.read(activeProfileSessionProvider.notifier) as MockActiveProfileSessionNotifier;

    // Profile 1
    sessionNotifier.state = ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true);
    await Future.delayed(Duration.zero);
    final coordinator1 = container.read(intelligenceNotificationCoordinatorProvider);
    coordinator1.processSummary(summary, 'p1');
    await Future.delayed(Duration.zero);
    verify(() => mockOrchestrator.notify(any())).called(1);
    clearInteractions(mockOrchestrator);

    // Switch to Profile 2
    sessionNotifier.state = ActiveProfileSession(profileId: 'p2', startedAt: DateTime.now(), pinVerified: true);
    await Future.delayed(Duration.zero);
    final coordinator2 = container.read(intelligenceNotificationCoordinatorProvider);
    
    coordinator2.processSummary(summary, 'p2');
    await Future.delayed(Duration.zero);
    verify(() => mockOrchestrator.notify(any())).called(1);
  });
}
