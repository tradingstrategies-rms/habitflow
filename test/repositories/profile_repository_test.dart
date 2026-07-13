import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow/core/services/database/database_service.dart';
import 'package:habitflow/features/profile/data/firestore_profile_repository.dart';
import 'package:habitflow/features/profile/domain/user_profile.dart';
import 'package:habitflow/features/profile/domain/family_role.dart';

class MockDatabaseService implements DatabaseService {
  Map<String, dynamic>? data;
  String? lastPath;
  Map<String, dynamic>? lastData;

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    lastPath = path;
    return data;
  }

  @override
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = true}) async {
    lastPath = path;
    lastData = data;
  }

  @override
  Future<void> deleteData(String path) async {
    lastPath = path;
  }

  @override
  String generateId() => 'id123';

  @override
  Future<List<Map<String, dynamic>>> getCollection(String path) async => [];

  @override
  Future<void> updateData(String path, Map<String, dynamic> data) async {}

  @override
  Stream<List<Map<String, dynamic>>> watchCollection(String path) => Stream.value([]);

  @override
  Stream<Map<String, dynamic>?> watchDocument(String path) => Stream.value(data);
}

void main() {
  group('FirestoreProfileRepository', () {
    late FirestoreProfileRepository repository;
    late MockDatabaseService mockDatabaseService;

    setUp(() {
      mockDatabaseService = MockDatabaseService();
      repository = FirestoreProfileRepository(mockDatabaseService);
    });

    test('getProfile returns UserProfile if data exists', () async {
      mockDatabaseService.data = {
        'uid': 'user123',
        'firstName': 'Test',
        'lastName': 'User',
        'displayName': 'Test User',
        'familyRole': 'parent',
      };

      final profile = await repository.getProfile('user123');

      expect(profile, isNotNull);
      expect(profile?.uid, 'user123');
      expect(profile?.familyRole, FamilyRole.parent);
      expect(mockDatabaseService.lastPath, 'profiles/user123');
    });

    test('getProfile returns null if no data', () async {
      mockDatabaseService.data = null;
      final profile = await repository.getProfile('user123');
      expect(profile, isNull);
    });

    test('saveProfile calls setData with correct path and data', () async {
      const profile = UserProfile(
        uid: 'user123',
        firstName: 'Test',
        lastName: 'User',
        displayName: 'Test User',
        country: 'US',
        language: 'en',
        timezone: 'UTC',
        familyRole: FamilyRole.parent,
      );

      await repository.saveProfile(profile);

      expect(mockDatabaseService.lastPath, 'profiles/user123');
      expect(mockDatabaseService.lastData?['uid'], 'user123');
      expect(mockDatabaseService.lastData?['familyRole'], 'parent');
    });
  });
}
