import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/controllers/challenges_controller.dart';
import 'challenges_repository_provider.dart';
import '../../../rewards/presentation/providers/rewards_controller_provider.dart';

import 'package:habitflow/features/challenges/presentation/providers/challenge_scheduler_provider.dart';

final challengesControllerProvider = Provider<ChallengesController>((ref) {
  final repository = ref.watch(challengesRepositoryProvider);
  final rewardsController = ref.watch(rewardsControllerProvider);
  final lifecycleService = ref.watch(challengeLifecycleServiceProvider);
  return ChallengesController(repository, rewardsController, lifecycleService, ref);
});
