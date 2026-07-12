import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

/// [FirestoreService] is the Firebase Firestore implementation of [DatabaseService].
class FirestoreService implements DatabaseService {
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    // Enable offline persistence
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  final FirebaseFirestore _firestore;

  @override
  Future<Map<String, dynamic>?> getDocument(String path) async {
    final snapshot = await _firestore.doc(path).get();
    return snapshot.data();
  }

  @override
  Stream<Map<String, dynamic>?> watchDocument(String path) {
    return _firestore.doc(path).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(String path) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollection(String path) {
    return _firestore.collection(path).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  @override
  Future<void> setData(String path, Map<String, dynamic> data, {bool merge = true}) async {
    await _firestore.doc(path).set(data, SetOptions(merge: merge));
  }

  @override
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).update(data);
  }

  @override
  Future<void> deleteData(String path) async {
    await _firestore.doc(path).delete();
  }

  @override
  String generateId() => _firestore.collection('tmp').doc().id;
}
