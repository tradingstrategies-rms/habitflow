enum PermissionType {
  completeHabit,
  createHabit,
  editHabit,
  deleteHabit,
  createSharedHabit,
  manageFamily,
  inviteMember,
  approveChildTask,
  switchProtectedProfile,
  manageChildProfiles;

  String get displayName {
    switch (this) {
      case PermissionType.completeHabit:
        return 'Complete Habit';
      case PermissionType.createHabit:
        return 'Create Habit';
      case PermissionType.editHabit:
        return 'Edit Habit';
      case PermissionType.deleteHabit:
        return 'Delete Habit';
      case PermissionType.createSharedHabit:
        return 'Create Shared Habit';
      case PermissionType.manageFamily:
        return 'Manage Family';
      case PermissionType.inviteMember:
        return 'Invite Member';
      case PermissionType.approveChildTask:
        return 'Approve Child Task';
      case PermissionType.switchProtectedProfile:
        return 'Switch Protected Profile';
      case PermissionType.manageChildProfiles:
        return 'Manage Child Profiles';
    }
  }
}
