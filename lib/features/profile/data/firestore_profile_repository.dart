import 'package:habitflow/core/services/database/database_service.dart';
import 'package:habitflow/features/profile/domain/profile_repository.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';

/// [FirestoreProfileRepository] implements [ProfileRepository] using [DatabaseService].
class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._databaseService);

  final DatabaseService _databaseService;
  static const String _collection = 'profiles';

  @override
  Future<UserProfile?> getProfile(String uid) async {
    final data = await _databaseService.getDocument('$_collection/$uid');
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Stream<UserProfile?> watchProfile(String uid) {
    return _databaseService
        .watchDocument('$_collection/$uid')
        .map((data) => data != null ? UserProfile.fromJson(data) : null);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _databaseService.setData('$_collection/${profile.uid}', profile.toJson());
  }

  @override
  Future<void> deleteProfile(String uid) async {
    await _databaseService.deleteData('$_collection/$uid');
  }
}
