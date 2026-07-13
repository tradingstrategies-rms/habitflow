// ignore_for_file: prefer_initializing_formals
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

/// [FirestoreService] is the Firebase Firestore implementation of [DatabaseService].
class FirestoreService implements DatabaseService {
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore;

  final FirebaseFirestore? _firestore;
  FirebaseFirestore? _initializedInstance;

  /// Lazily obtains and configures the [FirebaseFirestore] instance.
  FirebaseFirestore get _instance {
    if (_initializedInstance != null) return _initializedInstance!;
    
    final instance = _firestore ?? FirebaseFirestore.instance;
    // Enable offline persistence
    instance.settings = const Settings(persistenceEnabled: true);
    _initializedInstance = instance;
    return instance;
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final snapshot = await _instance.doc(path).get();
    return snapshot.data();
  }

  @override
  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return _instance.doc(path).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(String path) async {
    final snapshot = await _instance.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollection(String path) {
    return _instance.collection(path).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = true}) async {
    await _instance.doc(path).set(data, SetOptions(merge: merge));
  }

  @override
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _instance.doc(path).update(data);
  }

  @override
  Future<void> deleteData(String path) async {
    await _instance.doc(path).delete();
  }

  @override
  String generateId() => _instance.collection('tmp').doc().id;
}
