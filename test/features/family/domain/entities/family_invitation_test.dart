import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';

void main() {
  group('FamilyInvitation', () {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: 7));

    test('should create FamilyInvitation with correct fields', () {
      final invitation = FamilyInvitation(
        id: '1',
        familyId: 'family1',
        familyName: 'Smith Family',
        invitedEmail: 'test@example.com',
        invitedBy: 'user1',
        invitedByName: 'John Doe',
        invitedAt: now,
        status: InvitationStatus.pending,
        inviterProfileId: 'profile1',
        token: 'token123',
        createdAt: now,
        expiresAt: expiresAt,
      );

      expect(invitation.id, '1');
      expect(invitation.familyId, 'family1');
      expect(invitation.inviterProfileId, 'profile1');
      expect(invitation.token, 'token123');
      expect(invitation.createdAt, now);
      expect(invitation.expiresAt, expiresAt);
      expect(invitation.status, InvitationStatus.pending);
      expect(invitation.usedAt, isNull);
      expect(invitation.usedByProfileId, isNull);
    });

    test('isExpired should return true if expiresAt is in the past', () {
      final invitation = FamilyInvitation(
        id: '1',
        familyId: 'family1',
        familyName: 'Smith Family',
        invitedEmail: 'test@example.com',
        invitedBy: 'user1',
        invitedByName: 'John Doe',
        invitedAt: now,
        status: InvitationStatus.pending,
        inviterProfileId: 'profile1',
        token: 'token123',
        createdAt: now.subtract(const Duration(days: 10)),
        expiresAt: now.subtract(const Duration(days: 3)),
      );

      expect(invitation.isExpired, isTrue);
    });

    test('isPending should return true only if status is pending and not expired', () {
      final invitation = FamilyInvitation(
        id: '1',
        familyId: 'family1',
        familyName: 'Smith Family',
        invitedEmail: 'test@example.com',
        invitedBy: 'user1',
        invitedByName: 'John Doe',
        invitedAt: now,
        status: InvitationStatus.pending,
        inviterProfileId: 'profile1',
        token: 'token123',
        createdAt: now,
        expiresAt: expiresAt,
      );

      expect(invitation.isPending, isTrue);

      final expiredInvitation = invitation.copyWith(
        expiresAt: now.subtract(const Duration(hours: 1)),
      );
      expect(expiredInvitation.isPending, isFalse);
    });
  });
}
