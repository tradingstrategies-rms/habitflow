/// [DatabaseService] defines the interface for database operations.
abstract class DatabaseService {
  /// Fetches a document by path.
  Future<Map<String, dynamic>?> getDocument(String path);

  /// Streams a document by path.
  Stream<Map<String, dynamic>?> watchDocument(String path);

  /// Fetches a collection by path.
  Future<List<Map<String, dynamic>>> getCollection(String path);

  /// Streams a collection by path.
  Stream<List<Map<String, dynamic>>> watchCollection(String path);

  /// Creates or updates a document.
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = true});

  /// Updates specific fields in a document.
  Future<void> updateData(String path, Map<String, dynamic> data);

  /// Deletes a document.
  Future<void> deleteData(String path);

  /// Generates a unique ID.
  String generateId();
}

/// [NoOpDatabaseService] is a placeholder for development.
class NoOpDatabaseService implements DatabaseService {
  @override
  Future<Map<String, dynamic>?> getDocument(String path) async => null;

  @override
  Stream<Map<String, dynamic>?> watchDocument(String path) => Stream.value(null);

  @override
  Future<List<Map<String, dynamic>>> getCollection(String path) async => [];

  @override
  Stream<List<Map<String, dynamic>>> watchCollection(String path) => Stream.value([]);

  @override
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = true}) async {}

  @override
  Future<void> updateData(String path, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteData(String path) async {}

  @override
  String generateId() => '';
}
