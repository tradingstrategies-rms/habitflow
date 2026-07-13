import 'user_profile.dart';

/// [ProfileRepository] defines the interface for profile data operations.
abstract class ProfileRepository {
  /// Fetches a user profile by UID.
  Future<UserProfile?> getProfile(String uid);

  /// Streams a user profile by UID.
  Stream<UserProfile?> watchProfile(String uid);

  /// Creates or updates a user profile.
  Future<void> saveProfile(UserProfile profile);

  /// Deletes a user profile.
  Future<void> deleteProfile(String uid);
}
