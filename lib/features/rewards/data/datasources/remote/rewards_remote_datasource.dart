import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/reward_account_model.dart';
import '../../models/reward_transaction_model.dart';
import '../../../../../core/providers/firebase_providers.dart';

abstract class RewardsRemoteDataSource {
  Future<RewardAccountModel?> getAccount(String userId, String profileId);
  Future<void> saveAccount(String userId, RewardAccountModel account);
  Future<List<RewardTransactionModel>> getTransactions(String userId, String profileId);
  Future<void> addTransaction(String userId, RewardTransactionModel transaction);
}

class RewardsRemoteDataSourceImpl implements RewardsRemoteDataSource {
  final FirebaseFirestore _firestore;

  RewardsRemoteDataSourceImpl(this._firestore);

  CollectionReference _accountCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('reward_accounts');

  CollectionReference _transactionCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('reward_transactions');

  @override
  Future<RewardAccountModel?> getAccount(String userId, String profileId) async {
    final doc = await _accountCollection(userId).doc(profileId).get();
    if (!doc.exists) return null;
    return RewardAccountModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveAccount(String userId, RewardAccountModel account) async {
    await _accountCollection(userId).doc(account.profileId).set(account.toJson());
  }

  @override
  Future<List<RewardTransactionModel>> getTransactions(String userId, String profileId) async {
    final snapshot = await _transactionCollection(userId)
        .where('profileId', isEqualTo: profileId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => RewardTransactionModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTransaction(String userId, RewardTransactionModel transaction) async {
    await _transactionCollection(userId).doc(transaction.id).set(transaction.toJson());
  }
}

final rewardsRemoteDataSourceProvider = Provider<RewardsRemoteDataSource>((ref) {
  return RewardsRemoteDataSourceImpl(ref.watch(firestoreProvider));
});
