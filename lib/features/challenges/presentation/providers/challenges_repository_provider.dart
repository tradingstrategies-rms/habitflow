import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../../data/datasources/challenges_local_datasource.dart';
import '../../data/repositories/challenges_repository_impl.dart';

final challengesDataSourceProvider = Provider<ChallengesLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ChallengesLocalDatasourceImpl(prefs);
});

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) {
  final dataSource = ref.watch(challengesDataSourceProvider);
  return ChallengesRepositoryImpl(dataSource);
});
