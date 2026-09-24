import 'package:cloud_firestore/cloud_firestore.dart';

/// Generic Firestore helper used by all repositories.
/// Keeping this thin & generic keeps repositories testable and avoids
/// duplicating query boilerplate across the app (SOLID - single responsibility).
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get instance => _db;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  Future<DocumentReference<Map<String, dynamic>>> add(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).add(data);
  }

  Future<void> set(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return _db
        .collection(collectionPath)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  Future<void> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> delete(String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)? query,
  }) {
    Query<Map<String, dynamic>> q = _db.collection(collectionPath);
    if (query != null) q = query(q);
    return q.snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDoc(
    String collectionPath,
    String docId,
  ) {
    return _db.collection(collectionPath).doc(docId).snapshots();
  }
}
