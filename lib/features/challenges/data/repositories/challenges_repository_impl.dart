import '../../domain/entities/challenge.dart';
import '../../domain/entities/challenge_progress.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../datasources/challenges_local_datasource.dart';
import '../models/challenge_model.dart';
import '../models/challenge_progress_model.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesLocalDatasource _datasource;

  ChallengesRepositoryImpl(this._datasource);

  @override
  Future<List<Challenge>> getActiveChallenges() async {
    final models = await _datasource.getChallenges();
    return models.where((m) => m.isActive).map((m) => m.toEntity()).toList();
  }

  @override
  Future<Challenge?> getChallengeById(String id) async {
    final models = await _datasource.getChallenges();
    try {
      return models.firstWhere((m) => m.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ChallengeProgress?> getProgress(String challengeId, String profileId, {DateTime? periodStartDate}) async {
    final records = await _datasource.getProgressRecords();
    try {
      return records.firstWhere(
        (r) => r.challengeId == challengeId && 
               r.profileId == profileId && 
               (periodStartDate == null || r.periodStartDate == periodStartDate),
      ).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ChallengeProgress>> getAllProgressForProfile(String profileId) async {
    final records = await _datasource.getProgressRecords();
    return records.where((r) => r.profileId == profileId).map((r) => r.toEntity()).toList();
  }

  @override
  Future<void> saveProgress(ChallengeProgress progress) async {
    await _datasource.saveProgress(ChallengeProgressModel.fromEntity(progress));
  }

  @override
  Future<void> createChallenge(Challenge challenge) async {
    await _datasource.saveChallenge(ChallengeModel.fromEntity(challenge));
  }
}
