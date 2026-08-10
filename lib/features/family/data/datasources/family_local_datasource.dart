import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_circle_model.dart';
import '../models/family_profile_model.dart';
import '../models/parent_approval_model.dart';
import '../models/family_invitation_model.dart';
import '../models/shared_habit_model.dart';
import '../models/family_activity_model.dart';
import '../models/family_achievement_model.dart';
import '../../domain/entities/active_profile_session.dart';

abstract class FamilyLocalDatasource {
  Future<FamilyCircleModel?> getFamilyCircle();
  Future<FamilyCircleModel?> getFamilyCircleById(String id);
  Future<List<FamilyCircleModel>> getAllFamilyCircles();
  Future<void> createFamilyCircle(FamilyCircleModel circle);
  Future<void> updateFamilyCircle(FamilyCircleModel circle);
  Future<FamilyProfileModel?> getProfile(String profileId);
  Future<List<FamilyProfileModel>> getProfiles(String familyId);
  Future<void> createChildProfile(FamilyProfileModel profile);
  Future<void> createAdultProfile(FamilyProfileModel profile);
  Future<void> updateProfile(FamilyProfileModel profile);
  Future<void> deleteProfile(String profileId);
  
  // Parent PIN
  Future<void> saveParentPin(String pin);
  Future<String?> getParentPin();
  
  // Session
  Future<void> saveSession(ActiveProfileSession session);
  Future<ActiveProfileSession?> getSession();
  Future<void> clearSession();
  
  // Approvals
  Future<List<ParentApprovalModel>> getApprovals();
  Future<void> saveApproval(ParentApprovalModel approval);
  Future<void> deleteApproval(String id);
  Future<void> updateApproval(ParentApprovalModel approval);

  // Invitations
  Future<List<FamilyInvitationModel>> getInvitations();
  Future<void> saveInvitation(FamilyInvitationModel invitation);
  Future<void> deleteInvitation(String id);
  Future<void> updateInvitation(FamilyInvitationModel invitation);

  // Shared Habits
  Future<List<SharedHabitModel>> getSharedHabits();
  Future<void> saveSharedHabit(SharedHabitModel sharedHabit);
  Future<void> deleteSharedHabit(String id);
  Future<void> updateSharedHabit(SharedHabitModel sharedHabit);

  // Activity
  Future<List<FamilyActivityModel>> getActivities();
  Future<void> saveActivity(FamilyActivityModel activity);
  Stream<List<FamilyActivityModel>> watchActivities();

  // Achievements
  Future<List<FamilyAchievementModel>> getAchievements();
  Future<void> saveAchievements(List<FamilyAchievementModel> achievements);
}

class FamilyLocalDatasourceImpl implements FamilyLocalDatasource {
  final SharedPreferences _prefs;
  final _activityController = StreamController<List<FamilyActivityModel>>.broadcast();
  static const String _circleKey = 'family_circle';
  static const String _allCirclesKey = 'family_circles_all';
  static const String _profilesKey = 'family_profiles';
  static const String _pinKey = 'family_parent_pin';
  static const String _sessionKey = 'family_active_session';
  static const String _approvalsKey = 'family_approvals';
  static const String _invitationsKey = 'family_invitations';
  static const String _sharedHabitsKey = 'family_shared_habits';
  static const String _activitiesKey = 'family_activities';
  static const String _achievementsKey = 'family_achievements';

  FamilyLocalDatasourceImpl(this._prefs);

  @override
  Future<FamilyCircleModel?> getFamilyCircle() async {
    final jsonString = _prefs.getString(_circleKey);
    if (jsonString == null) return null;
    return FamilyCircleModel.fromJson(json.decode(jsonString));
  }

  @override
  Future<FamilyCircleModel?> getFamilyCircleById(String id) async {
    final circles = await getAllFamilyCircles();
    try {
      return circles.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FamilyCircleModel>> getAllFamilyCircles() async {
    final jsonString = _prefs.getString(_allCirclesKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => FamilyCircleModel.fromJson(j)).toList();
  }

  @override
  Future<void> createFamilyCircle(FamilyCircleModel circle) async {
    await _prefs.setString(_circleKey, json.encode(circle.toJson()));
    final circles = await getAllFamilyCircles();
    circles.add(circle);
    await _saveAllCircles(circles);
  }

  @override
  Future<void> updateFamilyCircle(FamilyCircleModel circle) async {
    await _prefs.setString(_circleKey, json.encode(circle.toJson()));
    final circles = await getAllFamilyCircles();
    final index = circles.indexWhere((c) => c.id == circle.id);
    if (index != -1) {
      circles[index] = circle;
      await _saveAllCircles(circles);
    }
  }

  @override
  Future<void> createAdultProfile(FamilyProfileModel profile) async {
    final profiles = await _getAllProfiles();
    profiles.add(profile);
    await _saveAllProfiles(profiles);
  }

  @override
  Future<List<FamilyInvitationModel>> getInvitations() async {
    final jsonString = _prefs.getString(_invitationsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => FamilyInvitationModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveInvitation(FamilyInvitationModel invitation) async {
    final invitations = await getInvitations();
    invitations.add(invitation);
    await _saveAllInvitations(invitations);
  }

  @override
  Future<void> deleteInvitation(String id) async {
    final invitations = await getInvitations();
    invitations.removeWhere((i) => i.id == id);
    await _saveAllInvitations(invitations);
  }

  @override
  Future<void> updateInvitation(FamilyInvitationModel invitation) async {
    final invitations = await getInvitations();
    final index = invitations.indexWhere((i) => i.id == invitation.id);
    if (index != -1) {
      invitations[index] = invitation;
      await _saveAllInvitations(invitations);
    }
  }

  @override
  Future<List<SharedHabitModel>> getSharedHabits() async {
    final jsonString = _prefs.getString(_sharedHabitsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => SharedHabitModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveSharedHabit(SharedHabitModel sharedHabit) async {
    final sharedHabits = await getSharedHabits();
    sharedHabits.add(sharedHabit);
    await _saveAllSharedHabits(sharedHabits);
  }

  @override
  Future<void> deleteSharedHabit(String id) async {
    final sharedHabits = await getSharedHabits();
    sharedHabits.removeWhere((h) => h.id == id);
    await _saveAllSharedHabits(sharedHabits);
  }

  @override
  Future<void> updateSharedHabit(SharedHabitModel sharedHabit) async {
    final sharedHabits = await getSharedHabits();
    final index = sharedHabits.indexWhere((h) => h.id == sharedHabit.id);
    if (index != -1) {
      sharedHabits[index] = sharedHabit;
      await _saveAllSharedHabits(sharedHabits);
    }
  }

  Future<void> _saveAllCircles(List<FamilyCircleModel> circles) async {
    final jsonList = circles.map((c) => c.toJson()).toList();
    await _prefs.setString(_allCirclesKey, json.encode(jsonList));
  }

  Future<void> _saveAllInvitations(List<FamilyInvitationModel> invitations) async {
    final jsonList = invitations.map((i) => i.toJson()).toList();
    await _prefs.setString(_invitationsKey, json.encode(jsonList));
  }

  Future<void> _saveAllSharedHabits(List<SharedHabitModel> sharedHabits) async {
    final jsonList = sharedHabits.map((h) => h.toJson()).toList();
    await _prefs.setString(_sharedHabitsKey, json.encode(jsonList));
  }

  @override
  Future<List<FamilyActivityModel>> getActivities() async {
    final jsonString = _prefs.getString(_activitiesKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => FamilyActivityModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveActivity(FamilyActivityModel activity) async {
    final activities = await getActivities();
    activities.add(activity);
    // Keep only last 100 for local storage performance
    if (activities.length > 100) {
      activities.removeAt(0);
    }
    await _saveAllActivities(activities);
    _activityController.add(activities);
  }

  @override
  Stream<List<FamilyActivityModel>> watchActivities() async* {
    yield await getActivities();
    yield* _activityController.stream;
  }

  Future<void> _saveAllActivities(List<FamilyActivityModel> activities) async {
    final jsonList = activities.map((a) => a.toJson()).toList();
    await _prefs.setString(_activitiesKey, json.encode(jsonList));
  }

  @override
  Future<List<FamilyAchievementModel>> getAchievements() async {
    final jsonString = _prefs.getString(_achievementsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => FamilyAchievementModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveAchievements(List<FamilyAchievementModel> achievements) async {
    final jsonList = achievements.map((a) => a.toJson()).toList();
    await _prefs.setString(_achievementsKey, json.encode(jsonList));
  }

  @override
  Future<FamilyProfileModel?> getProfile(String profileId) async {
    final profiles = await _getAllProfiles();
    try {
      return profiles.firstWhere((p) => p.id == profileId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FamilyProfileModel>> getProfiles(String familyId) async {
    final profiles = await _getAllProfiles();
    return profiles.where((p) => p.familyId == familyId).toList();
  }

  @override
  Future<void> createChildProfile(FamilyProfileModel profile) async {
    final profiles = await _getAllProfiles();
    profiles.add(profile);
    await _saveAllProfiles(profiles);
  }

  @override
  Future<void> updateProfile(FamilyProfileModel profile) async {
    final profiles = await _getAllProfiles();
    final index = profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      profiles[index] = profile;
      await _saveAllProfiles(profiles);
    }
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    final profiles = await _getAllProfiles();
    profiles.removeWhere((p) => p.id == profileId);
    await _saveAllProfiles(profiles);
  }

  @override
  Future<void> saveParentPin(String pin) async {
    await _prefs.setString(_pinKey, pin);
  }

  @override
  Future<String?> getParentPin() async {
    return _prefs.getString(_pinKey);
  }

  @override
  Future<void> saveSession(ActiveProfileSession session) async {
    final Map<String, dynamic> jsonMap = {
      'profileId': session.profileId,
      'pinVerified': session.pinVerified,
      'startedAt': session.startedAt.toIso8601String(),
    };
    await _prefs.setString(_sessionKey, json.encode(jsonMap));
  }

  @override
  Future<ActiveProfileSession?> getSession() async {
    final jsonString = _prefs.getString(_sessionKey);
    if (jsonString == null) return null;
    final map = json.decode(jsonString);
    return ActiveProfileSession(
      profileId: map['profileId'],
      pinVerified: map['pinVerified'],
      startedAt: DateTime.parse(map['startedAt']),
    );
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<List<ParentApprovalModel>> getApprovals() async {
    final jsonString = _prefs.getString(_approvalsKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => ParentApprovalModel.fromJson(j)).toList();
  }

  @override
  Future<void> saveApproval(ParentApprovalModel approval) async {
    final approvals = await getApprovals();
    approvals.add(approval);
    await _saveAllApprovals(approvals);
  }

  @override
  Future<void> deleteApproval(String id) async {
    final approvals = await getApprovals();
    approvals.removeWhere((a) => a.id == id);
    await _saveAllApprovals(approvals);
  }

  @override
  Future<void> updateApproval(ParentApprovalModel approval) async {
    final approvals = await getApprovals();
    final index = approvals.indexWhere((a) => a.id == approval.id);
    if (index != -1) {
      approvals[index] = approval;
      await _saveAllApprovals(approvals);
    }
  }

  Future<List<FamilyProfileModel>> _getAllProfiles() async {
    final jsonString = _prefs.getString(_profilesKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((j) => FamilyProfileModel.fromJson(j)).toList();
  }

  Future<void> _saveAllProfiles(List<FamilyProfileModel> profiles) async {
    final jsonList = profiles.map((p) => p.toJson()).toList();
    await _prefs.setString(_profilesKey, json.encode(jsonList));
  }

  Future<void> _saveAllApprovals(List<ParentApprovalModel> approvals) async {
    final jsonList = approvals.map((a) => a.toJson()).toList();
    await _prefs.setString(_approvalsKey, json.encode(jsonList));
  }
}
