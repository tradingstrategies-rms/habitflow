/// [StorageService] defines the interface for local key-value storage.
abstract class StorageService {
  /// Reads a value from storage.
  Future<T?> read<T>(String key);

  /// Writes a value to storage.
  Future<void> write<T>(String key, T value);

  /// Deletes a value from storage.
  Future<void> delete(String key);

  /// Checks if a key exists in storage.
  Future<bool> contains(String key);

  /// Clears all data from storage.
  Future<void> clear();
}
