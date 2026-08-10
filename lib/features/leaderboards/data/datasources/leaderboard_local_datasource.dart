import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_model.dart';
import '../../domain/enums/leaderboard_type.dart';
import '../../domain/enums/leaderboard_period.dart';

abstract class LeaderboardLocalDatasource {
  Future<LeaderboardModel?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId});
  Future<void> saveLeaderboard(LeaderboardModel leaderboard);
}

class LeaderboardLocalDatasourceImpl implements LeaderboardLocalDatasource {
  final SharedPreferences _prefs;
  static const String _storageKey = 'leaderboards_data';

  LeaderboardLocalDatasourceImpl(this._prefs);

  @override
  Future<LeaderboardModel?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) async {
    final leaderboards = await _getAll();
    try {
      final id = _generateId(type, period, familyId: familyId);
      return leaderboards.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLeaderboard(LeaderboardModel leaderboard) async {
    final leaderboards = await _getAll();
    final index = leaderboards.indexWhere((l) => l.id == leaderboard.id);
    if (index != -1) {
      leaderboards[index] = leaderboard;
    } else {
      leaderboards.add(leaderboard);
    }
    await _saveAll(leaderboards);
  }

  Future<List<LeaderboardModel>> _getAll() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => LeaderboardModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<LeaderboardModel> list) async {
    final jsonList = list.map((l) => l.toJson()).toList();
    await _prefs.setString(_storageKey, json.encode(jsonList));
  }

  String _generateId(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) {
    if (type == LeaderboardType.family && familyId != null) {
      return '${type.name}_${familyId}_${period.name}';
    }
    return '${type.name}_${period.name}';
  }
}
