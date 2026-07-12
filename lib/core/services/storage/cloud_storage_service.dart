import 'dart:io';

/// [CloudStorageService] defines the interface for cloud file storage.
abstract class CloudStorageService {
  /// Uploads a file to the specified path.
  Future<String> uploadFile(String path, File file);

  /// Downloads a file from the specified path.
  Future<File> downloadFile(String path, String localPath);

  /// Deletes a file from the specified path.
  Future<void> deleteFile(String path);

  /// Gets the download URL for a file.
  Future<String> getDownloadUrl(String path);
}

/// [NoOpCloudStorageService] is a placeholder for development.
class NoOpCloudStorageService implements CloudStorageService {
  @override
  Future<String> uploadFile(String path, File file) async => '';

  @override
  Future<File> downloadFile(String path, String localPath) async => File(localPath);

  @override
  Future<void> deleteFile(String path) async {}

  @override
  Future<String> getDownloadUrl(String path) async => '';
}
