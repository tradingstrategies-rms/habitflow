import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitflow/features/family/data/repositories/family_repository_impl.dart';
import 'package:habitflow/features/family/data/datasources/family_local_datasource.dart';
import 'package:habitflow/features/family/domain/entities/family_invitation.dart';
import 'package:habitflow/features/family/domain/enums/invitation_status.dart';

void main() {
  late FamilyRepositoryImpl repository;
  late FamilyLocalDatasource datasource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    datasource = FamilyLocalDatasourceImpl(prefs);
    repository = FamilyRepositoryImpl(datasource);
  });

  group('FamilyRepository Invitation Operations', () {
    final now = DateTime.now();
    final invitation = FamilyInvitation(
      id: 'inv1',
      familyId: 'fam1',
      familyName: 'Smiths',
      invitedEmail: 'test@example.com',
      invitedBy: 'user1',
      invitedByName: 'John',
      invitedAt: now,
      inviterProfileId: 'prof1',
      token: 'secure-token-123',
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      status: InvitationStatus.pending,
    );

    test('sendInvitation and getInvitationByToken', () async {
      await repository.sendInvitation(invitation);
      
      final result = await repository.getInvitationByToken('secure-token-123');
      expect(result, isNotNull);
      expect(result?.id, invitation.id);
      expect(result?.familyId, invitation.familyId);
    });

    test('acceptInvitation updates status and records usage', () async {
      await repository.sendInvitation(invitation);
      
      await repository.acceptInvitation('inv1', 'new-prof-id');
      
      final result = await repository.getInvitationByToken('secure-token-123');
      expect(result?.status, InvitationStatus.accepted);
      expect(result?.usedByProfileId, 'new-prof-id');
      expect(result?.usedAt, isNotNull);
    });

    test('revokeInvitation updates status to revoked', () async {
      await repository.sendInvitation(invitation);
      
      await repository.revokeInvitation('inv1');
      
      final result = await repository.getInvitationByToken('secure-token-123');
      expect(result?.status, InvitationStatus.revoked);
    });

    test('acceptInvitationWithToken works correctly', () async {
      await repository.sendInvitation(invitation);
      
      await repository.acceptInvitationWithToken('secure-token-123', 'prof3');
      
      final result = await repository.getInvitationByToken('secure-token-123');
      expect(result?.status, InvitationStatus.accepted);
      expect(result?.usedByProfileId, 'prof3');
    });
  });
}
