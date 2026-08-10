import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_progress.dart';
import 'challenges_repository_provider.dart';

import 'challenge_scheduler_provider.dart';

final activeChallengesProvider = FutureProvider.family<List<Challenge>, String>((ref, profileId) async {
  final repository = ref.watch(challengesRepositoryProvider);
  final allActive = await repository.getActiveChallenges();
  
  // Filter by eligible profile IDs if specified
  return allActive.where((c) {
    if (c.eligibleProfileIds.isEmpty) return true;
    return c.eligibleProfileIds.contains(profileId);
  }).toList();
});

final profileProgressProvider = FutureProvider.family<List<ChallengeProgress>, String>((ref, profileId) async {
  final scheduler = ref.watch(challengeSchedulerProvider);
  await scheduler.evaluateChallenges(profileId);

  final repository = ref.watch(challengesRepositoryProvider);
  return await repository.getAllProgressForProfile(profileId);
});

final challengeProgressProvider = FutureProvider.family<ChallengeProgress?, (String, String)>((ref, arg) async {
  final repository = ref.watch(challengesRepositoryProvider);
  return await repository.getProgress(arg.$1, arg.$2);
});

final completedChallengesProvider = FutureProvider.family<List<Challenge>, String>((ref, profileId) async {
  final allProgress = await ref.watch(profileProgressProvider(profileId).future);
  final completedIds = allProgress.where((p) => p.isCompleted).map((p) => p.challengeId).toSet();
  
  final repository = ref.watch(challengesRepositoryProvider);
  
  final List<Challenge> completed = [];
  for (final id in completedIds) {
    final c = await repository.getChallengeById(id);
    if (c != null) completed.add(c);
  }
  return completed;
});
