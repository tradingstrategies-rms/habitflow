// ignore_for_file: prefer_initializing_formals
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'cloud_storage_service.dart';

/// [FirebaseStorageService] is the Firebase Storage implementation of [CloudStorageService].
class FirebaseStorageService implements CloudStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;
  
  /// Lazily obtains the [FirebaseStorage] instance.
  FirebaseStorage get _instance => _storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(String path, File file) async {
    final ref = _instance.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  @override
  Future<File> downloadFile(String path, String localPath) async {
    final ref = _instance.ref().child(path);
    final file = File(localPath);
    await ref.writeToFile(file);
    return file;
  }

  @override
  Future<void> deleteFile(String path) async {
    await _instance.ref().child(path).delete();
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    return await _instance.ref().child(path).getDownloadURL();
  }
}
