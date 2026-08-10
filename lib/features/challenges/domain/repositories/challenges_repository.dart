import '../entities/challenge.dart';
import '../entities/challenge_progress.dart';

abstract class ChallengesRepository {
  Future<List<Challenge>> getActiveChallenges();
  Future<Challenge?> getChallengeById(String id);
  Future<ChallengeProgress?> getProgress(String challengeId, String profileId, {DateTime? periodStartDate});
  Future<List<ChallengeProgress>> getAllProgressForProfile(String profileId);
  Future<void> saveProgress(ChallengeProgress progress);
  Future<void> createChallenge(Challenge challenge); // Admin/System operation
}
