import '../entities/family_profile.dart';
import '../enums/family_role.dart';
import '../enums/permission_type.dart';
import '../enums/profile_type.dart';

class PermissionService {
  bool hasPermission(FamilyProfile profile, PermissionType permission) {
    switch (profile.role) {
      case FamilyRole.owner:
        return true;
      case FamilyRole.parent:
        return _getParentPermissions(permission);
      case FamilyRole.adultMember:
        return _getAdultMemberPermissions(permission);
      case FamilyRole.child:
        return _getChildPermissions(permission);
    }
  }

  bool _getParentPermissions(PermissionType permission) {
    switch (permission) {
      case PermissionType.completeHabit:
      case PermissionType.createHabit:
      case PermissionType.editHabit:
      case PermissionType.createSharedHabit:
      case PermissionType.inviteMember:
      case PermissionType.approveChildTask:
      case PermissionType.switchProtectedProfile:
      case PermissionType.manageChildProfiles:
        return true;
      case PermissionType.deleteHabit:
      case PermissionType.manageFamily:
        return false;
    }
  }

  bool _getAdultMemberPermissions(PermissionType permission) {
    switch (permission) {
      case PermissionType.completeHabit:
      case PermissionType.createHabit:
      case PermissionType.editHabit:
        return true;
      case PermissionType.deleteHabit:
      case PermissionType.createSharedHabit:
      case PermissionType.manageFamily:
      case PermissionType.inviteMember:
      case PermissionType.approveChildTask:
      case PermissionType.switchProtectedProfile:
      case PermissionType.manageChildProfiles:
        return false;
    }
  }

  bool _getChildPermissions(PermissionType permission) {
    return permission == PermissionType.completeHabit;
  }

  bool isChild(FamilyProfile profile) => profile.profileType == ProfileType.child;

  bool isAdult(FamilyProfile profile) => profile.profileType == ProfileType.adult;

  bool requiresPin(FamilyProfile profile) => profile.requiresPin;
}
