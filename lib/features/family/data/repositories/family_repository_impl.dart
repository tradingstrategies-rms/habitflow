import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_profile.dart';
import '../../domain/entities/parent_approval.dart';
import '../../domain/entities/active_profile_session.dart';
import '../../domain/entities/family_invitation.dart';
import '../../domain/enums/invitation_status.dart';
import '../../domain/entities/shared_habit.dart';
import '../../domain/entities/family_activity.dart';
import '../../domain/entities/family_achievement.dart';
import '../../domain/repositories/family_repository.dart';
import '../datasources/family_local_datasource.dart';
import '../models/family_circle_model.dart';
import '../models/family_profile_model.dart';
import '../models/parent_approval_model.dart';
import '../models/family_invitation_model.dart';
import '../models/shared_habit_model.dart';
import '../models/family_activity_model.dart';
import '../models/family_achievement_model.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyLocalDatasource _datasource;

  FamilyRepositoryImpl(this._datasource);

  @override
  Future<FamilyCircle?> getFamilyCircle() async {
    final model = await _datasource.getFamilyCircle();
    return model;
  }

  @override
  Future<FamilyCircle?> getFamilyCircleById(String familyId) async {
    final model = await _datasource.getFamilyCircleById(familyId);
    return model;
  }

  @override
  Future<void> createFamilyCircle(FamilyCircle circle) async =>
      await _datasource.createFamilyCircle(FamilyCircleModel.fromEntity(circle));

  @override
  Future<void> updateFamilyCircle(FamilyCircle circle) async =>
      await _datasource.updateFamilyCircle(FamilyCircleModel.fromEntity(circle));

  @override
  Future<void> deleteFamilyCircle(String familyId) async {}

  @override
  Future<List<FamilyProfile>> getProfiles(String familyId) async {
    final models = await _datasource.getProfiles(familyId);
    return models.map((m) => m as FamilyProfile).toList();
  }

  @override
  Future<FamilyProfile?> getProfile(String profileId) async {
    final model = await _datasource.getProfile(profileId);
    return model;
  }

  @override
  Future<void> createChildProfile(FamilyProfile profile) async {
    await _datasource.createChildProfile(FamilyProfileModel.fromEntity(profile));
  }

  @override
  Future<void> createAdultProfile(FamilyProfile profile) async {
    await _datasource.createAdultProfile(FamilyProfileModel.fromEntity(profile));
  }

  @override
  Future<void> updateProfile(FamilyProfile profile) async =>
      await _datasource.updateProfile(FamilyProfileModel.fromEntity(profile));

  @override
  Future<void> deleteProfile(String profileId) async => await _datasource.deleteProfile(profileId);

  @override
  Future<void> sendInvitation(FamilyInvitation invitation) async {
    await _datasource.saveInvitation(FamilyInvitationModel.fromEntity(invitation));
  }

  @override
  Future<List<FamilyInvitation>> getInvitationsForEmail(String email) async {
    final models = await _datasource.getInvitations();
    return models
        .where((m) => m.invitedEmail == email)
        .map((m) => m as FamilyInvitation)
        .toList();
  }

  @override
  Future<List<FamilyInvitation>> getInvitationsByFamilyId(String familyId) async {
    final models = await _datasource.getInvitations();
    return models
        .where((m) => m.familyId == familyId)
        .map((m) => m as FamilyInvitation)
        .toList();
  }

  @override
  Future<FamilyInvitation?> getInvitationByToken(String token) async {
    final models = await _datasource.getInvitations();
    try {
      return models.firstWhere((m) => m.token == token);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> acceptInvitation(String invitationId, String profileId) async {
    final invitations = await _datasource.getInvitations();
    final invitation = invitations.firstWhere((i) => i.id == invitationId);

    if (invitation.status != InvitationStatus.pending) {
      throw Exception('Invitation is not pending');
    }
    if (invitation.isExpired) {
      throw Exception('Invitation has expired');
    }

    final updatedInvitation = invitation.copyWith(
      status: InvitationStatus.accepted,
      usedAt: DateTime.now(),
      usedByProfileId: profileId,
    );

    await _datasource.updateInvitation(FamilyInvitationModel.fromEntity(updatedInvitation));
  }

  @override
  Future<void> acceptInvitationWithToken(String token, String profileId) async {
    final invitation = await getInvitationByToken(token);
    if (invitation == null) {
      throw Exception('Invitation not found');
    }
    await acceptInvitation(invitation.id, profileId);
  }

  @override
  Future<void> declineInvitation(String invitationId) async {
    final invitations = await _datasource.getInvitations();
    final invitation = invitations.firstWhere((i) => i.id == invitationId);
    final updatedInvitation = invitation.copyWith(status: InvitationStatus.declined);
    await _datasource.updateInvitation(FamilyInvitationModel.fromEntity(updatedInvitation));
  }

  @override
  Future<void> revokeInvitation(String invitationId) async {
    final invitations = await _datasource.getInvitations();
    final invitation = invitations.firstWhere((i) => i.id == invitationId);
    final updatedInvitation = invitation.copyWith(status: InvitationStatus.revoked);
    await _datasource.updateInvitation(FamilyInvitationModel.fromEntity(updatedInvitation));
  }

  @override
  Future<void> deleteInvitation(String invitationId) async {
    await _datasource.deleteInvitation(invitationId);
  }

  @override
  Future<List<ParentApproval>> getPendingApprovals(String parentProfileId) async {
    final approvals = await _datasource.getApprovals();
    return approvals.map((a) => a as ParentApproval).toList();
  }

  @override
  Future<void> createPendingApproval(ParentApproval approval) async {
    await _datasource.saveApproval(ParentApprovalModel.fromEntity(approval));
  }

  @override
  Future<List<ParentApproval>> getPendingApprovalsForChild(String childProfileId) async {
    final approvals = await _datasource.getApprovals();
    return approvals.where((a) => a.childProfileId == childProfileId).map((a) => a as ParentApproval).toList();
  }

  @override
  Future<void> cancelPendingApproval(String approvalId) async {
    await _datasource.deleteApproval(approvalId);
  }

  @override
  Future<void> approveHabit(String approvalId) async {
    // Note: Completion logic should be in Notifier/Service. 
    // This just updates the status or removes the request.
    await _datasource.deleteApproval(approvalId);
  }

  @override
  Future<void> rejectHabit(String approvalId) async {
    await _datasource.deleteApproval(approvalId);
  }

  @override
  Future<void> createSharedHabit(SharedHabit sharedHabit) async {
    await _datasource.saveSharedHabit(SharedHabitModel.fromEntity(sharedHabit));
  }

  @override
  Future<List<SharedHabit>> getSharedHabits(String familyId) async {
    final models = await _datasource.getSharedHabits();
    // Assuming familyId filtering if needed, but for now we reuse all
    return models.map((m) => m as SharedHabit).toList();
  }

  @override
  Future<SharedHabit?> getSharedHabitByHabitId(String habitId) async {
    final models = await _datasource.getSharedHabits();
    try {
      return models.firstWhere((m) => m.habitId == habitId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateSharedHabit(SharedHabit sharedHabit) async {
    await _datasource.updateSharedHabit(SharedHabitModel.fromEntity(sharedHabit));
  }

  @override
  Future<void> deleteSharedHabit(String sharedHabitId) async {
    await _datasource.deleteSharedHabit(sharedHabitId);
  }

  @override
  Future<void> recordActivity(FamilyActivity activity) async {
    await _datasource.saveActivity(FamilyActivityModel.fromEntity(activity));
  }

  @override
  Future<List<FamilyActivity>> getActivities(String familyId) async {
    final models = await _datasource.getActivities();
    return models.map((m) => m as FamilyActivity).toList();
  }

  @override
  Stream<List<FamilyActivity>> watchActivities(String familyId) {
    return _datasource.watchActivities().map((list) => list.map((m) => m as FamilyActivity).toList());
  }

  @override
  Future<List<FamilyAchievement>> getAchievements() async {
    final models = await _datasource.getAchievements();
    return models.map((m) => m as FamilyAchievement).toList();
  }

  @override
  Future<void> saveAchievements(List<FamilyAchievement> achievements) async {
    final models = achievements.map((a) => FamilyAchievementModel.fromEntity(a)).toList();
    await _datasource.saveAchievements(models);
  }

  @override
  Future<FamilyProfile?> getActiveProfile() async {
    final session = await _datasource.getSession();
    if (session == null) return null;
    return await _datasource.getProfile(session.profileId);
  }

  @override
  Future<void> setActiveProfile(String profileId) async {}

  @override
  Future<void> saveParentPin(String pin) async => await _datasource.saveParentPin(pin);

  @override
  Future<bool> verifyParentPin(String pin) async {
    final savedPin = await _datasource.getParentPin();
    return savedPin != null && savedPin == pin;
  }

  @override
  Future<bool> hasParentPin() async {
    final savedPin = await _datasource.getParentPin();
    return savedPin != null && savedPin.isNotEmpty;
  }

  @override
  Future<ActiveProfileSession?> getActiveProfileSession() async => await _datasource.getSession();

  @override
  Future<void> setActiveProfileSession(ActiveProfileSession session) async => 
      await _datasource.saveSession(session);

  @override
  Future<void> clearActiveProfileSession() async => await _datasource.clearSession();
}

