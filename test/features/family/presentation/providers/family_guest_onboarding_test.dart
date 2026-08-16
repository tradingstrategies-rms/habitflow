import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/entities/family_activity.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart' as family_enums;
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';
import 'package:habitflow/features/family/domain/enums/family_activity_type.dart';
import 'package:habitflow/features/family/presentation/providers/family_invitation_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/profile/data/profile_providers.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/domain/family_role.dart' as profile_enums;
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  late MockFamilyRepository mockRepo;
  late ProviderContainer container;

  final now = DateTime.now();
  final testInvitation = FamilyInvitation(
    id: 'inv1',
    familyId: 'fam1',
    familyName: 'Test Family',
    invitedEmail: 'guest@example.com',
    invitedBy: 'p1',
    invitedByName: 'Admin',
    invitedAt: now,
    status: InvitationStatus.pending,
    inviterProfileId: 'p1',
    token: 'token123',
    createdAt: now,
    expiresAt: now.add(const Duration(days: 7)),
  );

  setUp(() {
    mockRepo = MockFamilyRepository();
    
    registerFallbackValue(FamilyInvitation(
      id: '', familyId: '', familyName: '', invitedEmail: '',
      invitedBy: '', invitedByName: '', invitedAt: now,
      status: InvitationStatus.pending, inviterProfileId: '',
      token: '', createdAt: now, expiresAt: now,
    ));
    registerFallbackValue(FamilyProfile(
      id: '', familyId: '', displayName: '', profileType: ProfileType.adult,
      role: family_enums.FamilyRole.parent, requiresPin: true, createdAt: now,
    ));
    registerFallbackValue(ActiveProfileSession(
      profileId: '', pinVerified: false, startedAt: now,
    ));
    registerFallbackValue(FamilyActivity(
      id: '', familyId: '', profileId: '', profileName: '',
      type: FamilyActivityType.memberJoined, description: '', timestamp: now,
    ));

    container = ProviderContainer(
      overrides: [
        familyRepositoryProvider.overrideWithValue(mockRepo),
        userProfileProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );

    when(() => mockRepo.getProfiles(any())).thenAnswer((_) async => []);
    when(() => mockRepo.createAdultProfile(any())).thenAnswer((_) async {});
    when(() => mockRepo.recordActivity(any())).thenAnswer((_) async {});
    when(() => mockRepo.acceptInvitation(any(), any())).thenAnswer((_) async {});
    when(() => mockRepo.setActiveProfileSession(any())).thenAnswer((_) async {});
    when(() => mockRepo.getFamilyCircle()).thenAnswer((_) async => null);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
  });

  group('InvitationNotifier Guest Onboarding', () {
    test('acceptInvitation creates a new profile for a guest', () async {
      final notifier = container.read(invitationNotifierProvider.notifier);
      
      await notifier.acceptInvitation(testInvitation, guestName: 'Guest User');

      verify(() => mockRepo.createAdultProfile(any(that: predicate<FamilyProfile>((p) => p.displayName == 'Guest User')))).called(1);
      verify(() => mockRepo.acceptInvitation('inv1', any())).called(1);
      verify(() => mockRepo.setActiveProfileSession(any())).called(1);
      expect(container.read(invitationNotifierProvider).hasError, isFalse);
    });

    test('acceptInvitation reuses existing profile for authenticated user', () async {
      const authUser = UserProfile(
        uid: 'u1',
        email: 'user@example.com',
        firstName: 'Auth',
        lastName: 'User',
        displayName: 'Auth User',
        country: 'US',
        timezone: 'UTC',
        familyRole: profile_enums.FamilyRole.parent,
      );
      
      container = ProviderContainer(
        overrides: [
          familyRepositoryProvider.overrideWithValue(mockRepo),
          userProfileProvider.overrideWith((ref) => Stream.value(authUser)),
        ],
      );

      // Wait for userProfileProvider to emit
      await container.read(userProfileProvider.future);

      final existingProfile = FamilyProfile(
        id: 'p-existing',
        familyId: 'fam1',
        displayName: 'Auth User',
        profileType: ProfileType.adult,
        role: family_enums.FamilyRole.parent,
        userId: 'u1',
        requiresPin: true,
        createdAt: now,
      );

      when(() => mockRepo.getProfiles('fam1')).thenAnswer((_) async => [existingProfile]);

      final notifier = container.read(invitationNotifierProvider.notifier);
      await notifier.acceptInvitation(testInvitation);

      verifyNever(() => mockRepo.createAdultProfile(any()));
      verify(() => mockRepo.acceptInvitation('inv1', 'p-existing')).called(1);
      verify(() => mockRepo.setActiveProfileSession(any(that: predicate<ActiveProfileSession>((s) => s.profileId == 'p-existing')))).called(1);
    });
  });
}
