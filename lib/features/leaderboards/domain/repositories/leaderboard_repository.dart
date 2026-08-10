import '../entities/leaderboard.dart';
import '../enums/leaderboard_type.dart';
import '../enums/leaderboard_period.dart';

abstract class LeaderboardRepository {
  Future<Leaderboard?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId});
  Future<void> saveLeaderboard(Leaderboard leaderboard);
}
