import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/entities/family_circle.dart';
import 'package:habitflow/features/family/domain/entities/family_profile.dart';
import 'package:habitflow/features/family/domain/entities/active_profile_session.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';
import 'package:habitflow/features/family/domain/enums/family_role.dart';
import 'package:habitflow/features/family/domain/enums/profile_type.dart';
import 'package:habitflow/features/family/domain/repositories/family_repository.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';
import 'package:habitflow/features/family/presentation/screens/family_invitation_details_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockFamilyRepository extends Mock implements FamilyRepository {}

void main() {
  late MockFamilyRepository mockRepo;

  final now = DateTime.now();
  final testInvitation = FamilyInvitation(
    id: 'inv1',
    familyId: 'fam1',
    familyName: 'Test Family',
    invitedEmail: 'test@example.com',
    invitedBy: 'p1',
    invitedByName: 'Admin',
    invitedAt: now,
    status: InvitationStatus.pending,
    inviterProfileId: 'p1',
    token: 'token123',
    createdAt: now,
    expiresAt: now.add(const Duration(days: 7)),
  );

  final testCircle = FamilyCircle(
    id: 'fam1',
    name: 'Test Family',
    ownerProfileId: 'p1',
    createdAt: now,
  );

  final adultProfile = FamilyProfile(
    id: 'p1',
    familyId: 'fam1',
    displayName: 'Admin',
    profileType: ProfileType.adult,
    role: FamilyRole.owner,
    requiresPin: true,
    createdAt: now,
  );

  setUp(() {
    mockRepo = MockFamilyRepository();
    when(() => mockRepo.getInvitationByToken('token123')).thenAnswer((_) async => testInvitation);
    when(() => mockRepo.getFamilyCircle()).thenAnswer((_) async => testCircle);
    when(() => mockRepo.getProfiles(any())).thenAnswer((_) async => [adultProfile]);
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => null);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        familyRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: const MaterialApp(
        home: FamilyInvitationDetailsScreen(token: 'token123'),
      ),
    );
  }

  testWidgets('renders management UI for authorized adult of the same family', (WidgetTester tester) async {
    when(() => mockRepo.getActiveProfileSession()).thenAnswer((_) async => ActiveProfileSession(
      profileId: 'p1',
      pinVerified: true,
      startedAt: now,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invitation for'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Copy Link'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Revoke Invitation'), findsOneWidget);
  });

  testWidgets('renders acceptance UI for guest/other user', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('You\u0027re invited!'), findsOneWidget);
    expect(find.text('Join Test Family to track habits and grow together.'), findsOneWidget);
    expect(find.text('Accept & Join Family'), findsOneWidget);
  });

  testWidgets('renders expired state correctly', (WidgetTester tester) async {
    final expiredInvitation = testInvitation.copyWith(
      expiresAt: now.subtract(const Duration(days: 1)),
    );
    when(() => mockRepo.getInvitationByToken('token123')).thenAnswer((_) async => expiredInvitation);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invitation Invalid'), findsOneWidget);
    expect(find.text('This invitation has expired.'), findsOneWidget);
  });

  testWidgets('renders revoked state correctly', (WidgetTester tester) async {
    final revokedInvitation = testInvitation.copyWith(
      status: InvitationStatus.revoked,
    );
    when(() => mockRepo.getInvitationByToken('token123')).thenAnswer((_) async => revokedInvitation);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invitation Invalid'), findsOneWidget);
    expect(find.text('This invitation has been revoked by the inviter.'), findsOneWidget);
  });

  testWidgets('renders accepted state correctly', (WidgetTester tester) async {
    final acceptedInvitation = testInvitation.copyWith(
      status: InvitationStatus.accepted,
    );
    when(() => mockRepo.getInvitationByToken('token123')).thenAnswer((_) async => acceptedInvitation);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invitation Invalid'), findsOneWidget);
    expect(find.text('This invitation has already been used.'), findsOneWidget);
  });

  testWidgets('renders error for invalid token', (WidgetTester tester) async {
    when(() => mockRepo.getInvitationByToken('token123')).thenAnswer((_) async => null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Invitation Not Found'), findsOneWidget);
  });
}
