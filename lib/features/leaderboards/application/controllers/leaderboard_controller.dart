import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../rewards/domain/repositories/rewards_repository.dart';
import '../../../rewards/domain/enums/reward_type.dart';
import '../../../rewards/presentation/providers/rewards_repository_provider.dart';

class LeaderboardController {
  final LeaderboardRepository _repository;
  final Ref _ref;

  LeaderboardController(this._repository, this._ref);

  Future<Leaderboard?> getOrRefreshLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) async {
    final cached = await _repository.getLeaderboard(type, period, familyId: familyId);
    
    // Refresh if stale (5 mins) or if it's from a previous period
    if (cached == null || 
        DateTime.now().difference(cached.lastUpdatedAt).inMinutes > 5 ||
        _isLeaderboardFromOldPeriod(cached)) {
      return await refreshLeaderboard(type, period, familyId: familyId);
    }
    
    return cached;
  }

  bool _isLeaderboardFromOldPeriod(Leaderboard leaderboard) {
    final now = DateTime.now();
    DateTime periodStart;
    
    switch (leaderboard.period) {
      case LeaderboardPeriod.weekly:
        periodStart = now.subtract(Duration(days: now.weekday - 1));
        periodStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
        break;
      case LeaderboardPeriod.monthly:
        periodStart = DateTime(now.year, now.month, 1);
        break;
      case LeaderboardPeriod.allTime:
        return false;
    }
    
    return leaderboard.lastUpdatedAt.isBefore(periodStart);
  }

  Future<Leaderboard> refreshLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) async {
    List<LeaderboardEntry> entries = [];
    final rewardsRepo = _ref.read(rewardsRepositoryProvider);

    if (type == LeaderboardType.family) {
      final familyState = _ref.read(familyProvider);
      if (familyState.circle != null) {
        for (final profile in familyState.profiles) {
          final score = await _calculateScore(profile.id, period, rewardsRepo);
          entries.add(LeaderboardEntry(
            profileId: profile.id,
            displayName: profile.displayName,
            avatarUrl: profile.avatarUrl,
            score: score,
            rank: 0,
            period: period,
          ));
        }
      }
    }

    // Deterministic Sort: By score DESC, then by displayName ASC for stability
    entries.sort((a, b) {
      int cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.displayName.compareTo(b.displayName);
    });

    final rankedEntries = [
      for (int i = 0; i < entries.length; i++)
        entries[i].copyWith(rank: i + 1)
    ];

    final leaderboard = Leaderboard(
      id: _generateId(type, period, familyId: familyId),
      type: type,
      period: period,
      entries: rankedEntries,
      lastUpdatedAt: DateTime.now(),
    );

    await _repository.saveLeaderboard(leaderboard);
    return leaderboard;
  }

  Future<int> _calculateScore(String profileId, LeaderboardPeriod period, RewardsRepository rewardsRepo) async {
    if (period == LeaderboardPeriod.allTime) {
      final account = await rewardsRepo.getAccount(profileId);
      return account?.experience ?? 0;
    }

    final transactions = await rewardsRepo.getTransactions(profileId);
    final now = DateTime.now();
    DateTime periodStart;

    switch (period) {
      case LeaderboardPeriod.weekly:
        periodStart = now.subtract(Duration(days: now.weekday - 1));
        periodStart = DateTime(periodStart.year, periodStart.month, periodStart.day);
        break;
      case LeaderboardPeriod.monthly:
        periodStart = DateTime(now.year, now.month, 1);
        break;
      default:
        periodStart = DateTime(2000);
    }

    return transactions
        .where((t) => t.type == RewardType.xp && t.createdAt.isAfter(periodStart))
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  String _generateId(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) {
    if (type == LeaderboardType.family && familyId != null) {
      return '${type.name}_${familyId}_${period.name}';
    }
    return '${type.name}_${period.name}';
  }
}
