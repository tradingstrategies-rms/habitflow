import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'cloud_storage_service.dart';

/// [FirebaseStorageService] is the Firebase Storage implementation of [CloudStorageService].
class FirebaseStorageService implements CloudStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<File> downloadFile(String path, String localPath) async {
    final ref = _storage.ref().child(path);
    final file = File(localPath);
    await ref.writeToFile(file);
    return file;
  }

  @override
  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }
}
