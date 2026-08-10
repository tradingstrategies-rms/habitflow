import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/challenge_lifecycle_service.dart';
import '../../application/services/challenge_scheduler.dart';
import 'challenges_repository_provider.dart';

final challengeLifecycleServiceProvider = Provider<ChallengeLifecycleService>((ref) {
  return ChallengeLifecycleService();
});

final challengeSchedulerProvider = Provider<ChallengeScheduler>((ref) {
  final repository = ref.watch(challengesRepositoryProvider);
  final lifecycleService = ref.watch(challengeLifecycleServiceProvider);
  return ChallengeScheduler(repository, lifecycleService, ref);
});
