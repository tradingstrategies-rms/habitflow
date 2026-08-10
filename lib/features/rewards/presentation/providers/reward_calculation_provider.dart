import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/reward_calculation_service.dart';

/// Provider for [RewardCalculationService].
final rewardCalculationServiceProvider = Provider<RewardCalculationService>((ref) {
  return RewardCalculationService();
});
