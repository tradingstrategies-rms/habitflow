enum FamilyActivityType {
  familyCreated,
  memberJoined,
  childAdded,
  sharedHabitCreated,
  sharedHabitAssigned,
  habitCompleted,
  awaitingApproval,
  completionApproved,
  completionRejected,
  streakMilestone,
  achievementUnlocked;

  String get displayName {
    switch (this) {
      case FamilyActivityType.familyCreated:
        return 'Family Created';
      case FamilyActivityType.memberJoined:
        return 'Member Joined';
      case FamilyActivityType.childAdded:
        return 'Child Added';
      case FamilyActivityType.sharedHabitCreated:
        return 'Shared Habit Created';
      case FamilyActivityType.sharedHabitAssigned:
        return 'Shared Habit Assigned';
      case FamilyActivityType.habitCompleted:
        return 'Habit Completed';
      case FamilyActivityType.awaitingApproval:
        return 'Awaiting Approval';
      case FamilyActivityType.completionApproved:
        return 'Completion Approved';
      case FamilyActivityType.completionRejected:
        return 'Completion Rejected';
      case FamilyActivityType.streakMilestone:
        return 'Streak Milestone';
      case FamilyActivityType.achievementUnlocked:
        return 'Achievement Unlocked';
    }
  }
}
