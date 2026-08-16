import '../entities/family_circle.dart';
import '../entities/family_profile.dart';
import '../entities/parent_approval.dart';
import '../entities/active_profile_session.dart';
import '../entities/family_invitation.dart';
import '../entities/shared_habit.dart';
import '../entities/family_activity.dart';
import '../entities/family_achievement.dart';

abstract class FamilyRepository {
  // Family lifecycle
  Future<FamilyCircle?> getFamilyCircle();
  Future<FamilyCircle?> getFamilyCircleById(String familyId);
  Future<void> createFamilyCircle(FamilyCircle circle);
  Future<void> updateFamilyCircle(FamilyCircle circle);
  Future<void> deleteFamilyCircle(String familyId);

  // Profiles
  Future<List<FamilyProfile>> getProfiles(String familyId);
  Future<FamilyProfile?> getProfile(String profileId);
  Future<void> createChildProfile(FamilyProfile profile);
  Future<void> createAdultProfile(FamilyProfile profile);
  Future<void> updateProfile(FamilyProfile profile);
  Future<void> deleteProfile(String profileId);

  // Adult Invitations
  Future<void> sendInvitation(FamilyInvitation invitation);
  Future<List<FamilyInvitation>> getInvitationsForEmail(String email);
  Future<List<FamilyInvitation>> getInvitationsByFamilyId(String familyId);
  Future<FamilyInvitation?> getInvitationByToken(String token);
  Future<void> acceptInvitation(String invitationId, String profileId);
  Future<void> acceptInvitationWithToken(String token, String profileId);
  Future<void> declineInvitation(String invitationId);
  Future<void> revokeInvitation(String invitationId);
  Future<void> deleteInvitation(String invitationId);

  // Parent Approvals
  Future<List<ParentApproval>> getPendingApprovals(String parentProfileId);
  Future<void> createPendingApproval(ParentApproval approval);
  Future<List<ParentApproval>> getPendingApprovalsForChild(String childProfileId);
  Future<void> cancelPendingApproval(String approvalId);
  Future<void> approveHabit(String approvalId);
  Future<void> rejectHabit(String approvalId);

  // Shared Habits
  Future<void> createSharedHabit(SharedHabit sharedHabit);
  Future<List<SharedHabit>> getSharedHabits(String familyId);
  Future<SharedHabit?> getSharedHabitByHabitId(String habitId);
  Future<void> updateSharedHabit(SharedHabit sharedHabit);
  Future<void> deleteSharedHabit(String sharedHabitId);

  // Family Activity
  Future<void> recordActivity(FamilyActivity activity);
  Future<List<FamilyActivity>> getActivities(String familyId);
  Stream<List<FamilyActivity>> watchActivities(String familyId);

  // Achievements
  Future<List<FamilyAchievement>> getAchievements();
  Future<void> saveAchievements(List<FamilyAchievement> achievements);

  // Active Profile
  Future<FamilyProfile?> getActiveProfile();
  Future<void> setActiveProfile(String profileId);

  // Parent PIN & Session
  Future<void> saveParentPin(String pin);
  Future<bool> verifyParentPin(String pin);
  Future<bool> hasParentPin();
  Future<ActiveProfileSession?> getActiveProfileSession();
  Future<void> setActiveProfileSession(ActiveProfileSession session);
  Future<void> clearActiveProfileSession();
}
