import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/challenge_progress_model.dart';
import '../../../../../core/providers/firebase_providers.dart';

abstract class ChallengesRemoteDataSource {
  Future<List<ChallengeProgressModel>> getProgress(String userId, String profileId);
  Future<void> saveProgress(String userId, ChallengeProgressModel progress);
}

class ChallengesRemoteDataSourceImpl implements ChallengesRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChallengesRemoteDataSourceImpl(this._firestore);

  CollectionReference _progressCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('challenge_progress');

  @override
  Future<List<ChallengeProgressModel>> getProgress(String userId, String profileId) async {
    final snapshot = await _progressCollection(userId)
        .where('profileId', isEqualTo: profileId)
        .get();
    return snapshot.docs
        .map((doc) => ChallengeProgressModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveProgress(String userId, ChallengeProgressModel progress) async {
    final id = '${progress.challengeId}_${progress.profileId}_${progress.periodStartDate.millisecondsSinceEpoch}';
    await _progressCollection(userId).doc(id).set(progress.toJson());
  }
}

final challengesRemoteDataSourceProvider = Provider<ChallengesRemoteDataSource>((ref) {
  return ChallengesRemoteDataSourceImpl(ref.watch(firestoreProvider));
});
