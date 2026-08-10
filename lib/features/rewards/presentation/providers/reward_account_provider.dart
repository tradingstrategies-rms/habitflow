import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reward_account.dart';
import 'rewards_repository_provider.dart';

/// Provider for a specific profile's [RewardAccount].
final rewardAccountProvider = FutureProvider.family<RewardAccount?, String>((ref, profileId) async {
  final repository = ref.watch(rewardsRepositoryProvider);
  return await repository.getAccount(profileId);
});
