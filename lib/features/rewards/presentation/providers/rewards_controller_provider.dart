import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/controllers/rewards_controller.dart';
import 'rewards_repository_provider.dart';

/// Provider for [RewardsController].
final rewardsControllerProvider = Provider<RewardsController>((ref) {
  final repository = ref.watch(rewardsRepositoryProvider);
  return RewardsController(repository, ref);
});
