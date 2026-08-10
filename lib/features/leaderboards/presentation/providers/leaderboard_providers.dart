import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/core/theme/theme_controller.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../data/datasources/leaderboard_local_datasource.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';
import '../../application/controllers/leaderboard_controller.dart';
import '../../../family/presentation/providers/family_provider.dart';

final leaderboardDataSourceProvider = Provider<LeaderboardLocalDatasource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LeaderboardLocalDatasourceImpl(prefs);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dataSource = ref.watch(leaderboardDataSourceProvider);
  return LeaderboardRepositoryImpl(dataSource);
});

final leaderboardControllerProvider = Provider<LeaderboardController>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return LeaderboardController(repository, ref);
});

final currentLeaderboardProvider = FutureProvider.family<Leaderboard?, (LeaderboardType, LeaderboardPeriod, String?)>((ref, arg) async {
  // Watching familyProvider ensures we refresh when profiles are added/removed
  ref.watch(familyProvider);

  final controller = ref.watch(leaderboardControllerProvider);
  return await controller.getOrRefreshLeaderboard(arg.$1, arg.$2, familyId: arg.$3);
});

final profileRankingProvider = Provider.family<LeaderboardEntry?, (LeaderboardType, LeaderboardPeriod, String, String?)>((ref, arg) {
  final leaderboardAsync = ref.watch(currentLeaderboardProvider((arg.$1, arg.$2, arg.$4)));
  return leaderboardAsync.maybeWhen(
    data: (leaderboard) {
      if (leaderboard == null) return null;
      try {
        return leaderboard.entries.firstWhere((e) => e.profileId == arg.$3);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
