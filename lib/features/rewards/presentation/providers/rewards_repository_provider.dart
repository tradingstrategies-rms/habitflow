import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../../data/datasources/rewards_local_datasource.dart';
import '../../data/repositories/rewards_repository_impl.dart';

/// Provider for [RewardsLocalDatasource].
final rewardsDataSourceProvider = Provider<RewardsLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RewardsLocalDatasourceImpl(prefs);
});

/// Provider for [RewardsRepository].
final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  final dataSource = ref.watch(rewardsDataSourceProvider);
  return RewardsRepositoryImpl(dataSource);
});
