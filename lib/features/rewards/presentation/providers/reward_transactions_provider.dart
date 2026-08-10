import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reward_transaction.dart';
import 'rewards_repository_provider.dart';

/// Provider for a specific profile's reward history.
final rewardTransactionsProvider = FutureProvider.family<List<RewardTransaction>, String>((ref, profileId) async {
  final repository = ref.watch(rewardsRepositoryProvider);
  return await repository.getTransactions(profileId);
});
