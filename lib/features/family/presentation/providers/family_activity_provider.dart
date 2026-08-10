import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/family_activity.dart';
import '../../domain/enums/family_activity_type.dart';
import 'family_provider.dart';

enum ActivityFilter {
  all,
  habits,
  approvals,
  invitations,
  achievements,
  sharedHabits;

  String get displayName {
    switch (this) {
      case ActivityFilter.all: return 'All';
      case ActivityFilter.habits: return 'Habits';
      case ActivityFilter.approvals: return 'Approvals';
      case ActivityFilter.invitations: return 'Invitations';
      case ActivityFilter.achievements: return 'Achievements';
      case ActivityFilter.sharedHabits: return 'Shared Habits';
    }
  }
}

final familyActivityFilterProvider = StateProvider<ActivityFilter>((ref) => ActivityFilter.all);

final familyActivitiesProvider = StreamProvider<List<FamilyActivity>>((ref) {
  final family = ref.watch(familyProvider).circle;
  if (family == null) return Stream.value([]);
  
  final repository = ref.watch(familyRepositoryProvider);
  return repository.watchActivities(family.id).map((list) {
    final sorted = List<FamilyActivity>.from(list);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  });
});

final filteredFamilyActivitiesProvider = Provider<AsyncValue<List<FamilyActivity>>>((ref) {
  final activitiesAsync = ref.watch(familyActivitiesProvider);
  final filter = ref.watch(familyActivityFilterProvider);
  
  return activitiesAsync.whenData((activities) {
    if (filter == ActivityFilter.all) return activities;
    
    return activities.where((activity) {
      switch (filter) {
        case ActivityFilter.habits:
          return activity.type == FamilyActivityType.habitCompleted;
        case ActivityFilter.approvals:
          return [
            FamilyActivityType.awaitingApproval,
            FamilyActivityType.completionApproved,
            FamilyActivityType.completionRejected,
          ].contains(activity.type);
        case ActivityFilter.invitations:
          return activity.type == FamilyActivityType.memberJoined;
        case ActivityFilter.achievements:
          return activity.type == FamilyActivityType.achievementUnlocked;
        case ActivityFilter.sharedHabits:
          return [
            FamilyActivityType.sharedHabitCreated,
            FamilyActivityType.sharedHabitAssigned,
          ].contains(activity.type);
        default:
          return true;
      }
    }).toList();
  });
});
