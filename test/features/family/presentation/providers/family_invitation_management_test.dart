import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';
import 'package:habitflow/features/family/presentation/providers/family_invitation_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  late MockFamilyRepository mockRepo;
  late ProviderContainer container;

  final testCircle = FamilyCircle(
    id: 'f1',
    name: 'Test Family',
    ownerProfileId: 'p1',
    createdAt: DateTime.now(),
  );

  final adultProfile = FamilyProfile(
    id: 'p1',
    familyId: 'f1',
    displayName: 'Adult',
    profileType: ProfileType.adult,
    role: FamilyRole.parent,
    requiresPin: true,
    createdAt: DateTime.now(),
  );

  final childProfile = FamilyProfile(
    id: 'p2',
    familyId: 'f1',
    displayName: 'Child',
    profileType: ProfileType.child,
    role: FamilyRole.child,
    requiresPin: false,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepo = MockFamilyRepository();
    registerFallbackValue(FamilyInvitation(
      id: '',
      familyId: '',
      familyName: '',
      invitedEmail: '',
      invitedBy: '',
      invitedByName: '',
      invitedAt: DateTime.now(),
      status: InvitationStatus.pending,
      inviterProfileId: '',
      token: '',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now(),
    ));
    registerFallbackValue(ActiveProfileSession(
      profileId: '',
      pinVerified: false,
      startedAt: DateTime.now(),
    ));

    container = ProviderContainer(
      overrides: [
        familyRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    // Default mocks
    when(() => mockRepo.getFamilyCircle()).thenAnswer((_) async => testCircle);
    when(() => mockRepo.getProfiles(any())).thenAnswer((_) async => [adultProfile, childProfile]);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
    when(() => mockRepo.setActiveProfileSession(any())).thenAnswer((_) async {});
  });

  group('InvitationNotifier', () {
    test('sendInvitation works for authorized adult', () async {
      when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => ActiveProfileSession(
        profileId: 'p1',
        pinVerified: true,
        startedAt: DateTime.now(),
      ));
      when(() => mockRepo.sendInvitation(any())).thenAnswer((_) async {});

      // Trigger initialization
      await container.read(familyProvider.notifier).loadFamily();
      await container.read(activeProfileSessionProvider.notifier).startSession('p1', true);

      final notifier = container.read(invitationNotifierProvider.notifier);
      await notifier.sendInvitation('test@example.com', 'f1', 'Test Family');

      verify(() => mockRepo.sendInvitation(any())).called(1);
      expect(container.read(invitationNotifierProvider).hasError, isFalse);
    });

    test('sendInvitation fails for unauthorized child', () async {
      when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => ActiveProfileSession(
        profileId: 'p2',
        pinVerified: false,
        startedAt: DateTime.now(),
      ));

      await container.read(familyProvider.notifier).loadFamily();
      await container.read(activeProfileSessionProvider.notifier).startSession('p2', false);

      final notifier = container.read(invitationNotifierProvider.notifier);
      await notifier.sendInvitation('test@example.com', 'f1', 'Test Family');

      expect(container.read(invitationNotifierProvider).hasError, isTrue);
      verifyNever(() => mockRepo.sendInvitation(any()));
    });

    test('revokeInvitation works for authorized adult', () async {
      when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => ActiveProfileSession(
        profileId: 'p1',
        pinVerified: true,
        startedAt: DateTime.now(),
      ));
      when(() => mockRepo.revokeInvitation(any())).thenAnswer((_) async {});

      await container.read(familyProvider.notifier).loadFamily();
      await container.read(activeProfileSessionProvider.notifier).startSession('p1', true);

      final notifier = container.read(invitationNotifierProvider.notifier);
      await notifier.revokeInvitation('inv1');

      verify(() => mockRepo.revokeInvitation('inv1')).called(1);
    });
  });

  group('familyOutboundInvitationsProvider', () {
    test('loads invitations for current family', () async {
      final invitations = [
        FamilyInvitation(
          id: 'inv1',
          familyId: 'f1',
          familyName: 'Test Family',
          invitedEmail: 'test@example.com',
          invitedBy: 'p1',
          invitedByName: 'Adult',
          invitedAt: DateTime.now(),
          status: InvitationStatus.pending,
          inviterProfileId: 'p1',
          token: 'token1',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ),
      ];

      when(() => mockRepo.getInvitationsByFamilyId('f1')).thenAnswer((_) async => invitations);

      await container.read(familyProvider.notifier).loadFamily();
      
      final result = await container.read(familyOutboundInvitationsProvider.future);
      expect(result.length, 1);
      expect(result[0].id, 'inv1');
    });
  });
}
