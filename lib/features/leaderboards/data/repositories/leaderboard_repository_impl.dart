import '../../domain/entities/leaderboard.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_local_datasource.dart';
import '../models/leaderboard_model.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardLocalDatasource _datasource;

  LeaderboardRepositoryImpl(this._datasource);

  @override
  Future<Leaderboard?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) async {
    final model = await _datasource.getLeaderboard(type, period, familyId: familyId);
    return model?.toEntity();
  }

  @override
  Future<void> saveLeaderboard(Leaderboard leaderboard) async {
    await _datasource.saveLeaderboard(LeaderboardModel.fromEntity(leaderboard));
  }
}
