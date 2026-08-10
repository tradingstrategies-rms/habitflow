import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:habitflow/features/family/domain/entities/family_achievement.dart';
import 'package:habitflow/features/family/domain/entities/family_activity.dart';
import 'package:habitflow/features/family/domain/enums/family_activity_type.dart';
import 'package:habitflow/features/family/presentation/providers/family_activity_provider.dart';
import 'package:habitflow/features/family/presentation/providers/family_provider.dart';

import 'package:habitflow/features/rewards/presentation/providers/rewards_controller_provider.dart';
import 'package:habitflow/features/family/presentation/providers/active_profile_session_provider.dart';

final familyAchievementsProvider = StateNotifierProvider<FamilyAchievementNotifier, List<FamilyAchievement>>((ref) {
  return FamilyAchievementNotifier(ref);
});

class FamilyAchievementNotifier extends StateNotifier<List<FamilyAchievement>> {
  final Ref _ref;
  late final List<FamilyAchievement> _templates;

  FamilyAchievementNotifier(this._ref) : super([]) {
    _templates = [
      const FamilyAchievement(id: 'fam_1', name: 'First Family Created', description: 'Begin your journey together.', icon: '👨‍👩‍👧‍👦', targetValue: 1, category: 'Family'),
      const FamilyAchievement(id: 'fam_shared', name: 'First Shared Habit', description: 'Create a habit for the whole family.', icon: '🤝', targetValue: 1, category: 'Family'),
      const FamilyAchievement(id: 'fam_3', name: 'Family of 3', description: 'Grow your circle to 3 members.', icon: '🏠', targetValue: 3, category: 'Family'),
      const FamilyAchievement(id: 'fam_5', name: 'Family of 5', description: 'Grow your circle to 5 members.', icon: '🏰', targetValue: 5, category: 'Family'),
      const FamilyAchievement(id: 'streak_7', name: '7 Day Family Streak', description: '7 days of consistency.', icon: '🔥', targetValue: 7, category: 'Consistency'),
      const FamilyAchievement(id: 'shared_1', name: 'Shared Success', description: 'Complete your first shared habit.', icon: '✅', targetValue: 1, category: 'Shared Habits'),
      const FamilyAchievement(id: 'shared_10', name: 'Team Players', description: 'Complete 10 shared habits.', icon: '🏆', targetValue: 10, category: 'Shared Habits'),
      const FamilyAchievement(id: 'child_1', name: 'Approved!', description: 'Get your first habit approved by a parent.', icon: '⭐', targetValue: 1, category: 'Children'),
      const FamilyAchievement(id: 'parent_1', name: 'First Approval', description: 'Approve your child\'s first completion.', icon: '👮', targetValue: 1, category: 'Parents'),
      const FamilyAchievement(id: 'goal_1', name: 'Goal Getters', description: 'Complete your first family goal.', icon: '🎖️', targetValue: 1, category: 'Goals'),
    ];
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(familyRepositoryProvider);
    final saved = await repo.getAchievements();
    
    if (saved.isEmpty) {
      state = _templates;
    } else {
      // Merge saved progress with templates in case new achievements were added
      state = _templates.map((t) {
        final s = saved.firstWhere((s) => s.id == t.id, orElse: () => t);
        return t.copyWith(currentValue: s.currentValue, unlockedAt: s.unlockedAt);
      }).toList();
    }

    _setupListeners();
  }

  void _setupListeners() {
    // 1. Family Members Check
    _ref.listen(familyProvider, (prev, next) {
      if (next.circle != null) {
        _updateProgress('fam_1', 1);
        _updateProgress('fam_3', next.profiles.length.toDouble());
        _updateProgress('fam_5', next.profiles.length.toDouble());
      }
    });

    // 2. Shared Habits Check
    _ref.listen(sharedHabitsProvider, (prev, next) {
      final habits = next.value ?? [];
      if (habits.isNotEmpty) {
        _updateProgress('fam_shared', 1);
      }
    });

    // 3. Completions & Approvals Check
    // We can listen to activities for a simple event-driven check
    _ref.listen(familyActivitiesProvider, (prev, next) {
      final activities = next.value ?? [];
      if (activities.isEmpty) return;

      final latest = activities.first;
      
      switch (latest.type) {
        case FamilyActivityType.completionApproved:
          _incrementProgress('child_1');
          _incrementProgress('parent_1');
          _incrementProgress('shared_1');
          _incrementProgress('shared_10');
          break;
        case FamilyActivityType.streakMilestone:
          // metadata contains the streak count
          final streak = double.tryParse(latest.metadata ?? '0') ?? 0;
          if (streak >= 7) _updateProgress('streak_7', streak);
          break;
        case FamilyActivityType.achievementUnlocked:
           if (latest.description.contains('Goal')) {
             _incrementProgress('goal_1');
           }
           break;
        default: break;
      }
    });
  }

  void _updateProgress(String id, double value) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;

    final achievement = state[index];
    if (achievement.isUnlocked) return;

    if (value >= achievement.targetValue) {
      _unlock(index);
    } else if (value > achievement.currentValue) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) state[i].copyWith(currentValue: value) else state[i]
      ];
      _save();
    }
  }

  void _incrementProgress(String id) {
    final index = state.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _updateProgress(id, state[index].currentValue + 1);
  }

  void _unlock(int index) {
    final achievement = state[index].copyWith(
      currentValue: state[index].targetValue,
      unlockedAt: DateTime.now(),
    );

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) achievement else state[i]
    ];

    _save();
    _notifyUnlock(achievement);
  }

  void _notifyUnlock(FamilyAchievement achievement) {
    // Record Activity
    final familyId = _ref.read(familyProvider).circle?.id;
    if (familyId != null) {
      _ref.read(familyRepositoryProvider).recordActivity(FamilyActivity(
        id: const Uuid().v4(),
        familyId: familyId,
        type: FamilyActivityType.achievementUnlocked,
        description: 'New Family Achievement: ${achievement.name}! ${achievement.icon}',
        timestamp: DateTime.now(),
      ));
    }

    // Award Reward to active profile
    final profileId = _ref.read(activeProfileSessionProvider)?.profileId;
    if (profileId != null) {
      _ref.read(rewardsControllerProvider).awardAchievement(profileId, achievement.id, achievement.name);
    }

    // Trigger celebration event for UI
    _ref.read(newAchievementEventProvider.notifier).state = achievement;
  }

  Future<void> _save() async {
    await _ref.read(familyRepositoryProvider).saveAchievements(state);
  }
}

final newAchievementEventProvider = StateProvider<FamilyAchievement?>((ref) => null);
