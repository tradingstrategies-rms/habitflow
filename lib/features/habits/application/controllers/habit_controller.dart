import 'package:uuid/uuid.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../../../family/domain/repositories/family_repository.dart';
import '../../../family/domain/entities/family_activity.dart';
import '../../../family/domain/enums/family_activity_type.dart';
import '../services/habit_streak_service.dart';

import '../../../rewards/application/controllers/rewards_controller.dart';
import '../../../challenges/application/controllers/challenges_controller.dart';

/// [HabitController] orchestrates habit business operations.
class HabitController {
  final HabitRepository _repository;
  final HabitCompletionRepository _completionRepository;
  final FamilyRepository? _familyRepository;
  final HabitStreakService? _streakService;
  final RewardsController? _rewardsController;
  final ChallengesController? _challengesController;

  HabitController(
    this._repository, 
    this._completionRepository, 
    [this._familyRepository, this._streakService, this._rewardsController, this._challengesController]
  );

  Future<void> createHabit(Habit habit) async {
    try {
      await _repository.createHabit(habit);
    } catch (e) {
      throw Exception('Failed to create habit: $e');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _repository.deleteHabit(id);
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  Future<void> archiveHabit(String id) async {
    try {
      await _repository.archiveHabit(id);
    } catch (e) {
      throw Exception('Failed to archive habit: $e');
    }
  }

  Future<void> restoreHabit(String id) async {
    try {
      await _repository.restoreHabit(id);
    } catch (e) {
      throw Exception('Failed to restore habit: $e');
    }
  }

  Future<void> completeHabit(String habitId, DateTime date, {String? profileId}) async {
    try {
      final completion = HabitCompletion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: habitId,
        profileId: profileId,
        completionDate: date,
        completed: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _completionRepository.saveCompletion(completion);

      // Record Activity if in family context
      final familyRepo = _familyRepository;
      if (familyRepo != null && profileId != null) {
        final familyCircle = await familyRepo.getFamilyCircle();
        if (familyCircle != null) {
          final profile = await familyRepo.getProfile(profileId);
          final habit = await _repository.getHabitById(habitId);
          
          await familyRepo.recordActivity(FamilyActivity(
            id: const Uuid().v4(),
            familyId: familyCircle.id,
            profileId: profileId,
            profileName: profile?.displayName,
            profileAvatarUrl: profile?.avatarUrl,
            type: FamilyActivityType.habitCompleted,
            description: '${profile?.displayName ?? 'Someone'} completed "${habit?.title ?? 'a habit'}"',
            metadata: habitId,
            timestamp: DateTime.now(),
          ));

          // Check for Streak Milestones
          if (_streakService != null) {
            final completions = await _completionRepository.getCompletionsForHabit(habitId, profileId: profileId);
            final streak = _streakService.calculateCurrentStreak(completions);
            
            if (streak > 0 && (streak == 7 || streak == 30 || streak == 100 || streak % 50 == 0)) {
               await familyRepo.recordActivity(FamilyActivity(
                id: const Uuid().v4(),
                familyId: familyCircle.id,
                profileId: profileId,
                profileName: profile?.displayName,
                profileAvatarUrl: profile?.avatarUrl,
                type: FamilyActivityType.streakMilestone,
                description: '${profile?.displayName ?? 'Someone'} reached a $streak day streak on "${habit?.title ?? 'a habit'}"! 🔥',
                metadata: '$streak',
                timestamp: DateTime.now(),
              ));

              // Reward streak milestone
              if (_rewardsController != null) {
                await _rewardsController.awardStreakMilestone(profileId, streak, habit?.title ?? 'a habit');
              }
            }
          }

          // Award habit completion reward
          if (_rewardsController != null) {
            await _rewardsController.awardHabitCompletion(profileId, habitId, habit?.title ?? 'a habit');
          }

          // Update Challenge Progress
          if (_challengesController != null) {
            // 1. Generic habit challenges
            // We could search for active challenges of type 'habit' and increment them
            // For now, let's assume we have a way to identify related challenges.
            // Simplified: The controller will handle finding eligible challenges.
            await _challengesController.incrementProgressByRelatedId(profileId, habitId, 1);
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to mark habit as complete: $e');
    }
  }

  Future<void> uncompleteHabit(String habitId, DateTime date, {String? profileId}) async {
    try {
      // Note: Repository might need update to handle profileId in removal
      await _completionRepository.removeCompletion(habitId, date);
    } catch (e) {
      throw Exception('Failed to uncomplete habit: $e');
    }
  }

  Future<void> toggleCompletion(String habitId, bool isCompleted, {String? profileId}) async {
    final today = DateTime.now();
    try {
      if (isCompleted) {
        await uncompleteHabit(habitId, today, profileId: profileId);
      } else {
        await completeHabit(habitId, today, profileId: profileId);
      }
    } catch (e) {
      throw Exception('Failed to toggle habit completion: $e');
    }
  }

  Future<List<Habit>> loadHabits() async {
    try {
      return await _repository.getAllHabits();
    } catch (e) {
      throw Exception('Failed to load habits: $e');
    }
  }

  Future<Habit?> getHabit(String id) async {
    try {
      return await _repository.getHabitById(id);
    } catch (e) {
      throw Exception('Failed to retrieve habit: $e');
    }
  }

  Future<List<Habit>> getTodayHabits() async {
    try {
      return await _repository.getTodayHabits();
    } catch (e) {
      throw Exception('Failed to load today\'s habits: $e');
    }
  }
}
