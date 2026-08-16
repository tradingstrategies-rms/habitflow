import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/notifications/application/notification_orchestrator.dart';
import 'package:habitflow/core/notifications/application/notification_providers.dart';
import 'package:habitflow/core/notifications/domain/notification_payload.dart';
import 'package:habitflow/core/notifications/domain/notification_type.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart' as family_p;
import 'package:habitflow/features/reward_store/application/services/reward_approval_notification_coordinator.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_redemption.dart';
import 'package:habitflow/features/reward_store/domain/enums/redemption_status.dart';
import 'package:habitflow/features/reward_store/presentation/providers/reward_store_providers.dart';
import 'package:habitflow/features/reward_store/domain/entities/reward_item.dart';
import 'package:habitflow/features/reward_store/domain/enums/reward_category.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationOrchestrator extends Mock implements NotificationOrchestrator {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFamilyRepository extends Mock implements FamilyRepository {}

class MockActiveProfileNotifier extends ActiveProfileNotifier {
  MockActiveProfileNotifier(super.ref, {FamilyProfile? initialState}) {
    state = initialState;
  }
}

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
      type: NotificationType.rewardApproval,
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

  final childProfile = FamilyProfile(
    id: 'c1',
    familyId: 'f1',
    displayName: 'Child',
    profileType: ProfileType.child,
    role: FamilyRole.child,
    requiresPin: false,
    createdAt: DateTime.now(),
  );

  final parentProfile = FamilyProfile(
    id: 'p1',
    familyId: 'f1',
    displayName: 'Parent',
    profileType: ProfileType.adult,
    role: FamilyRole.parent,
    requiresPin: true,
    createdAt: DateTime.now(),
  );

  const rewardItem = RewardItem(
    id: 'i1',
    title: 'Movie Night',
    description: 'Watch a movie',
    pointsCost: 100,
    category: RewardCategory.experience,
  );

  group('RewardApprovalNotificationCoordinator', () {
    test('notifies authorized parent when new pending redemption appears', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref, initialState: parentProfile)),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true))),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(profiles: [childProfile, parentProfile])
          )),
          rewardItemByIdProvider('i1').overrideWith((ref) => rewardItem),
        ],
      );

      final coordinator = container.read(rewardApprovalNotificationCoordinatorProvider);
      final ref = container.readProviderElement(rewardApprovalNotificationCoordinatorProvider);

      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'c1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.pending,
        createdAt: DateTime.now(),
      );

      coordinator.processRedemptions(ref, [redemption]);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any())).called(1);
    });

    test('does NOT notify if the active profile is the child', () async {
       final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref, initialState: childProfile)),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: ActiveProfileSession(profileId: 'c1', startedAt: DateTime.now(), pinVerified: true))),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(profiles: [childProfile, parentProfile])
          )),
          rewardItemByIdProvider('i1').overrideWith((ref) => rewardItem),
        ],
      );

      final coordinator = container.read(rewardApprovalNotificationCoordinatorProvider);
      final ref = container.readProviderElement(rewardApprovalNotificationCoordinatorProvider);

      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'c1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.pending,
        createdAt: DateTime.now(),
      );

      coordinator.processRedemptions(ref, [redemption]);
      await Future.delayed(const Duration(milliseconds: 20));

      verifyNever(() => mockOrchestrator.notify(any()));
    });

    test('deduplicates repeated observations of the same redemption', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref, initialState: parentProfile)),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo, initialState: ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true))),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(profiles: [childProfile, parentProfile])
          )),
          rewardItemByIdProvider('i1').overrideWith((ref) => rewardItem),
        ],
      );

      final coordinator = container.read(rewardApprovalNotificationCoordinatorProvider);
      final ref = container.readProviderElement(rewardApprovalNotificationCoordinatorProvider);

      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'c1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.pending,
        createdAt: DateTime.now(),
      );

      coordinator.processRedemptions(ref, [redemption]);
      coordinator.processRedemptions(ref, [redemption]);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any())).called(1);
    });

    test('resets state on profile switch', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          notificationOrchestratorProvider.overrideWithValue(mockOrchestrator),
          activeProfileProvider.overrideWith((ref) => MockActiveProfileNotifier(ref)),
          activeProfileSessionProvider.overrideWith((ref) => MockActiveProfileSessionNotifier(mockRepo)),
          family_p.familyProvider.overrideWith((ref) => MockFamilyNotifier(
            mockRepo, 
            ref, 
            initialState: family_p.FamilyState(profiles: [childProfile, parentProfile])
          )),
          rewardItemByIdProvider('i1').overrideWith((ref) => rewardItem),
        ],
      );

      final activeProfileNotifier = container.read(activeProfileProvider.notifier) as MockActiveProfileNotifier;
      final sessionNotifier = container.read(activeProfileSessionProvider.notifier) as MockActiveProfileSessionNotifier;

      activeProfileNotifier.state = parentProfile;
      sessionNotifier.state = ActiveProfileSession(profileId: 'p1', startedAt: DateTime.now(), pinVerified: true);
      await Future.delayed(Duration.zero);
      
      final coordinator1 = container.read(rewardApprovalNotificationCoordinatorProvider);
      final ref1 = container.readProviderElement(rewardApprovalNotificationCoordinatorProvider);

      final redemption = RewardRedemption(
        id: 'r1',
        profileId: 'c1',
        rewardItemId: 'i1',
        pointsSpent: 100,
        status: RedemptionStatus.pending,
        createdAt: DateTime.now(),
      );

      coordinator1.processRedemptions(ref1, [redemption]);
      await Future.delayed(const Duration(milliseconds: 20));
      verify(() => mockOrchestrator.notify(any())).called(1);
      clearInteractions(mockOrchestrator);

      // Switch profile
      sessionNotifier.state = ActiveProfileSession(profileId: 'p1_alt', startedAt: DateTime.now(), pinVerified: true);
      await Future.delayed(Duration.zero);
      
      final coordinator2 = container.read(rewardApprovalNotificationCoordinatorProvider);
      final ref2 = container.readProviderElement(rewardApprovalNotificationCoordinatorProvider);

      coordinator2.processRedemptions(ref2, [redemption]);
      await Future.delayed(const Duration(milliseconds: 20));

      verify(() => mockOrchestrator.notify(any())).called(1);
    });
  });
}
