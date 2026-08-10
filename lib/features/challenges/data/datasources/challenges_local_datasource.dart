import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

abstract class ChallengesLocalDatasource {
  Future<List<ChallengeModel>> getChallenges();
  Future<void> saveChallenge(ChallengeModel challenge);
  Future<List<ChallengeProgressModel>> getProgressRecords();
  Future<void> saveProgress(ChallengeProgressModel progress);
}

class ChallengesLocalDatasourceImpl implements ChallengesLocalDatasource {
  final SharedPreferences _prefs;
  static const String _challengesKey = 'challenges_list';
  static const String _progressKey = 'challenges_progress';

  ChallengesLocalDatasourceImpl(this._prefs);

  @override
  Future<List<ChallengeModel>> getChallenges() async {
    final jsonString = _prefs.getString(_challengesKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => ChallengeModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveChallenge(ChallengeModel challenge) async {
    final challenges = await getChallenges();
    final index = challenges.indexWhere((c) => c.id == challenge.id);
    if (index != -1) {
      challenges[index] = challenge;
    } else {
      challenges.add(challenge);
    }
    await _saveAllChallenges(challenges);
  }

  @override
  Future<List<ChallengeProgressModel>> getProgressRecords() async {
    final jsonString = _prefs.getString(_progressKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((j) => ChallengeProgressModel.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveProgress(ChallengeProgressModel progress) async {
    final records = await getProgressRecords();
    final index = records.indexWhere(
      (r) => r.challengeId == progress.challengeId && r.profileId == progress.profileId,
    );
    if (index != -1) {
      records[index] = progress;
    } else {
      records.add(progress);
    }
    await _saveAllProgress(records);
  }

  Future<void> _saveAllChallenges(List<ChallengeModel> challenges) async {
    final jsonList = challenges.map((c) => c.toJson()).toList();
    await _prefs.setString(_challengesKey, json.encode(jsonList));
  }

  Future<void> _saveAllProgress(List<ChallengeProgressModel> progress) async {
    final jsonList = progress.map((p) => p.toJson()).toList();
    await _prefs.setString(_progressKey, json.encode(jsonList));
  }
}
