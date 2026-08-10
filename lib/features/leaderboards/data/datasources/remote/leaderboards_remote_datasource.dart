import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard_model.dart';
import '../../../domain/enums/leaderboard_type.dart';
import '../../../domain/enums/leaderboard_period.dart';
import '../../../../../../../core/providers/firebase_providers.dart';

abstract class LeaderboardsRemoteDataSource {
  Future<LeaderboardModel?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId});
  Future<void> saveLeaderboard(LeaderboardModel leaderboard);
}

class LeaderboardsRemoteDataSourceImpl implements LeaderboardsRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeaderboardsRemoteDataSourceImpl(this._firestore);

  @override
  Future<LeaderboardModel?> getLeaderboard(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) async {
    final docId = _generateId(type, period, familyId: familyId);
    final doc = await _firestore.collection('leaderboards').doc(docId).get();
    if (!doc.exists) return null;
    return LeaderboardModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> saveLeaderboard(LeaderboardModel leaderboard) async {
    await _firestore.collection('leaderboards').doc(leaderboard.id).set(leaderboard.toJson());
  }

  String _generateId(LeaderboardType type, LeaderboardPeriod period, {String? familyId}) {
    if (type == LeaderboardType.family && familyId != null) {
      return '${type.name}_${familyId}_${period.name}';
    }
    return '${type.name}_${period.name}';
  }
}

final leaderboardsRemoteDataSourceProvider = Provider<LeaderboardsRemoteDataSource>((ref) {
  return LeaderboardsRemoteDataSourceImpl(ref.watch(firestoreProvider));
});
