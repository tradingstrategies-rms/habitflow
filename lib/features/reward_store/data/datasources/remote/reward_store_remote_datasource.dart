import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reward_redemption_model.dart';
import '../../../../../core/providers/firebase_providers.dart';

abstract class RewardStoreRemoteDataSource {
  Future<List<RewardRedemptionModel>> getRedemptions(String userId, String profileId);
  Future<void> saveRedemption(String userId, RewardRedemptionModel redemption);
}

class RewardStoreRemoteDataSourceImpl implements RewardStoreRemoteDataSource {
  final FirebaseFirestore _firestore;

  RewardStoreRemoteDataSourceImpl(this._firestore);

  CollectionReference _redemptionCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('reward_redemptions');

  @override
  Future<List<RewardRedemptionModel>> getRedemptions(String userId, String profileId) async {
    final snapshot = await _redemptionCollection(userId)
        .where('profileId', isEqualTo: profileId)
        .get();
    return snapshot.docs
        .map((doc) => RewardRedemptionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveRedemption(String userId, RewardRedemptionModel redemption) async {
    await _redemptionCollection(userId).doc(redemption.id).set(redemption.toJson());
  }
}

final rewardStoreRemoteDataSourceProvider = Provider<RewardStoreRemoteDataSource>((ref) {
  return RewardStoreRemoteDataSourceImpl(ref.watch(firestoreProvider));
});
