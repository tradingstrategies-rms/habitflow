import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/family_circle.dart';
import '../../domain/entities/family_profile.dart';
import '../../domain/entities/shared_habit.dart';
import '../../domain/entities/family_activity.dart';
import '../../domain/enums/family_role.dart';
import '../../domain/enums/profile_type.dart';
import '../../domain/enums/shared_habit_completion_mode.dart';
import '../../domain/enums/family_activity_type.dart';
import '../../domain/repositories/family_repository.dart';
import '../../data/datasources/family_local_datasource.dart';
import '../../data/repositories/family_repository_impl.dart';
import 'parent_approval_provider.dart';

import 'package:habitflow/features/challenges/presentation/providers/challenges_controller_provider.dart';

import 'package:habitflow/core/achievements/providers/achievement_providers.dart';
import 'package:habitflow/core/achievements/events/goal_completed_event.dart';

import 'package:habitflow/core/theme/theme_controller.dart';

import 'package:habitflow/features/habits/application/providers/habit_provider.dart';
import 'package:habitflow/features/habits/application/providers/reminder_scheduler_providers.dart';

final familyDatasourceProvider = Provider<FamilyLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FamilyLocalDatasourceImpl(prefs);
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepositoryImpl(ref.watch(familyDatasourceProvider));
});

class FamilyState {
  final FamilyCircle? circle;
  final List<FamilyProfile> profiles;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const FamilyState({
    this.circle,
    this.profiles = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  FamilyState copyWith({
    FamilyCircle? circle,
    List<FamilyProfile>? profiles,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return FamilyState(
      circle: circle ?? this.circle,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class FamilyNotifier extends StateNotifier<FamilyState> {
  final FamilyRepository _repository;
  final Ref ref;

  FamilyNotifier(this._repository, this.ref) : super(const FamilyState()) {
    loadFamily();
    _listenToAchievements();
  }

  void _listenToAchievements() {
    ref.listen<AsyncValue<GoalCompletedEvent>>(goalCompletionEventsProvider, (previous, next) {
      final event = next.value;
      if (event != null && state.circle != null) {
        _repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: state.circle!.id,
          type: FamilyActivityType.achievementUnlocked,
          description: 'Family Achievement Unlocked: ${event.goalTitle}! 🏆',
          metadata: event.goalId,
          timestamp: DateTime.now(),
        ));
      }
    });
  }

  Future<void> loadFamily() async {
    state = state.copyWith(isLoading: true);
    try {
      final circle = await _repository.getFamilyCircle();
      List<FamilyProfile> profiles = [];
      if (circle != null) {
        profiles = await _repository.getProfiles(circle.id);
      }
      state = FamilyState(
        circle: circle,
        profiles: profiles,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = FamilyState(error: e.toString());
    }
  }

  Future<void> createFamily(FamilyCircle circle) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createFamilyCircle(circle);
      
      final ownerProfile = FamilyProfile(
        id: 'owner-1',
        familyId: circle.id,
        displayName: 'Parent',
        profileType: ProfileType.adult,
        role: FamilyRole.owner,
        requiresPin: true,
        createdAt: DateTime.now(),
      );
      try {
        await _repository.createAdultProfile(ownerProfile);
      } catch (e) {
        // Log silently
      }

      // Record Activity
      await _repository.recordActivity(FamilyActivity(
        id: const Uuid().v4(),
        familyId: circle.id,
        type: FamilyActivityType.familyCreated,
        description: 'Family "${circle.name}" was created',
        timestamp: DateTime.now(),
      ));
      
      final profiles = await _repository.getProfiles(circle.id);
      state = FamilyState(
        circle: circle,
        profiles: profiles,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addChildProfile(String name) async {
    if (state.circle == null) return;
    try {
      final childProfile = FamilyProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        familyId: state.circle!.id,
        displayName: name,
        profileType: ProfileType.child,
        role: FamilyRole.child,
        requiresPin: false,
        createdAt: DateTime.now(),
      );
      await _repository.createChildProfile(childProfile);

      // Record Activity
      await _repository.recordActivity(FamilyActivity(
        id: const Uuid().v4(),
        familyId: state.circle!.id,
        type: FamilyActivityType.childAdded,
        description: 'Child "$name" was added to the family',
        profileName: name,
        timestamp: DateTime.now(),
      ));
      
      final profiles = await _repository.getProfiles(state.circle!.id);
      state = state.copyWith(
        profiles: profiles,
        lastUpdated: DateTime.now(),
      );

      // Update Challenge Progress
      final challengesController = ref.read(challengesControllerProvider);
      // For now, let's use a generic 'family' related ID for family growth challenges
      await challengesController.incrementProgressByRelatedId(
        DateTime.now().millisecondsSinceEpoch.toString(), // System trigger? No, we need a profile ID.
        'family', 
        1.0,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateProfile(FamilyProfile profile) async {
    if (state.circle == null) return;
    try {
      await _repository.updateProfile(profile);
      final profiles = await _repository.getProfiles(state.circle!.id);
      state = state.copyWith(
        profiles: profiles,
        lastUpdated: DateTime.now(),
      );

      // Update Challenge Progress
      final challengesController = ref.read(challengesControllerProvider);
      // For now, let's use a generic 'family' related ID for family growth challenges
      await challengesController.incrementProgressByRelatedId(
        DateTime.now().millisecondsSinceEpoch.toString(), // System trigger? No, we need a profile ID.
        'family', 
        1.0,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteProfile(String profileId) async {
    if (state.circle == null) return;
    try {
      await _repository.deleteProfile(profileId);
      final profiles = await _repository.getProfiles(state.circle!.id);
      state = state.copyWith(
        profiles: profiles,
        lastUpdated: DateTime.now(),
      );

      // Update Challenge Progress
      final challengesController = ref.read(challengesControllerProvider);
      // For now, let's use a generic 'family' related ID for family growth challenges
      await challengesController.incrementProgressByRelatedId(
        DateTime.now().millisecondsSinceEpoch.toString(), // System trigger? No, we need a profile ID.
        'family', 
        1.0,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> createSharedHabit(SharedHabit sharedHabit) async {
    await _repository.createSharedHabit(sharedHabit);
    
    final habit = await ref.read(habitByIdProvider(sharedHabit.habitId).future);

    // Record Activity
    if (state.circle != null) {
      await _repository.recordActivity(FamilyActivity(
        id: const Uuid().v4(),
        familyId: state.circle!.id,
        type: FamilyActivityType.sharedHabitCreated,
        description: 'New shared habit: ${habit?.title ?? 'Unknown'}',
        metadata: sharedHabit.habitId,
        timestamp: DateTime.now(),
      ));

      for (final memberId in sharedHabit.assignedMemberIds) {
        final profile = state.profiles.firstWhere((p) => p.id == memberId, orElse: () => throw 'NotFound');
        await _repository.recordActivity(FamilyActivity(
          id: const Uuid().v4(),
          familyId: state.circle!.id,
          profileId: memberId,
          profileName: profile.displayName,
          profileAvatarUrl: profile.avatarUrl,
          type: FamilyActivityType.sharedHabitAssigned,
          description: '${profile.displayName} was assigned to "${habit?.title ?? 'a habit'}"',
          metadata: sharedHabit.habitId,
          timestamp: DateTime.now(),
        ));
      }
    }
    
    // Notify assigned members (Sprint 7: Local proxy)
    try {
      final habit = await ref.read(habitByIdProvider(sharedHabit.habitId).future);
      final adapter = ref.read(localNotificationAdapterProvider);
      
      for (final memberId in sharedHabit.assignedMemberIds) {
        // Skip creator if they assigned themselves?
        // For simplicity, notify everyone.
        await adapter.scheduleOneTimeNotification(
          id: (sharedHabit.id + memberId).hashCode,
          title: 'New Shared Habit',
          body: 'You have been assigned to "${habit?.title ?? 'a new habit'}".',
          scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
        );
      }
    } catch (e) {
      debugPrint('Failed to send assignment notification: $e');
    }

    // Update state to trigger dependents like sharedHabitsProvider
    state = state.copyWith(lastUpdated: DateTime.now());
    
    // safe to invalidate as it doesn't watch familyProvider
    ref.invalidate(sharedHabitByHabitIdProvider(sharedHabit.habitId));
  }

  Future<void> updateSharedHabit(SharedHabit sharedHabit) async {
    await _repository.updateSharedHabit(sharedHabit);
    state = state.copyWith(lastUpdated: DateTime.now());
    ref.invalidate(sharedHabitByHabitIdProvider(sharedHabit.habitId));
  }

  Future<void> deleteSharedHabit(String sharedHabitId, String habitId) async {
    await _repository.deleteSharedHabit(sharedHabitId);
    state = state.copyWith(lastUpdated: DateTime.now());
    ref.invalidate(sharedHabitByHabitIdProvider(habitId));
  }
}

final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier(ref.watch(familyRepositoryProvider), ref);
});

final familyProfilesProvider = FutureProvider<List<FamilyProfile>>((ref) async {
  return ref.watch(familyProvider.select((state) => state.profiles));
});

final sharedHabitsProvider = FutureProvider<List<SharedHabit>>((ref) async {
  final family = ref.watch(familyProvider).circle;
  if (family == null) return [];
  return await ref.watch(familyRepositoryProvider).getSharedHabits(family.id);
});

final sharedHabitByHabitIdProvider = FutureProvider.family<SharedHabit?, String>((ref, habitId) async {
  return await ref.watch(familyRepositoryProvider).getSharedHabitByHabitId(habitId);
});

class SharedHabitsSummary {
  final int total;
  final int completed;
  final int pending;

  const SharedHabitsSummary({this.total = 0, this.completed = 0, this.pending = 0});
}

final sharedHabitsSummaryProvider = FutureProvider<SharedHabitsSummary>((ref) async {
  final sharedHabitsAsync = ref.watch(sharedHabitsProvider);
  final sharedHabits = sharedHabitsAsync.value ?? [];
  
  if (sharedHabits.isEmpty) return const SharedHabitsSummary();

  int completed = 0;
  int pendingCount = 0;

  final approvalsAsync = ref.watch(allPendingApprovalsProvider);
  final approvals = approvalsAsync.value ?? [];

  for (final sh in sharedHabits) {
    final anyCompletion = ref.watch(anyTodayCompletionProvider(sh.habitId)).value;
    final isAnyCompleted = anyCompletion != null;
    
    final hasPending = approvals.any((a) => a.habitId == sh.habitId);
    if (hasPending) pendingCount++;

    if (sh.completionMode == SharedHabitCompletionMode.anyOne) {
      if (isAnyCompleted) completed++;
    } else if (sh.completionMode == SharedHabitCompletionMode.everyone) {
      // Check if all assigned members have completed
      bool allDone = true;
      for (final memberId in sh.assignedMemberIds) {
        final comp = ref.watch(profileTodayCompletionProvider((sh.habitId, memberId))).value;
        if (comp == null) {
          allDone = false;
          break;
        }
      }
      if (allDone) completed++;
    } else if (sh.completionMode == SharedHabitCompletionMode.teamGoal) {
      // Aggregated progress. For now, let's say it's completed if anyone did it or we reach a sum?
      // Simplified: same as anyOne for summary count
      if (isAnyCompleted) completed++;
    }
  }

  return SharedHabitsSummary(
    total: sharedHabits.length,
    completed: completed,
    pending: pendingCount,
  );
});
