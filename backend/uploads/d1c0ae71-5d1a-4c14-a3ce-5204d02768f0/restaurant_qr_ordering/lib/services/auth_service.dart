import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Thin wrapper around FirebaseAuth. Handles:
/// - Anonymous auth for customers (so Firestore rules can identify them)
/// - Email/password auth for chef & admin
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Anonymous sign-in used for customers scanning a QR code.
  /// Ensures every customer has a stable uid for order tracking without
  /// forcing them through a signup flow.
  Future<User?> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  /// Email/password login used by chef & admin.
  Future<UserModel?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (cred.user == null) return null;
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(cred.user!.uid)
        .get();
    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'no-profile',
        message: 'No staff profile found for this account.',
      );
    }
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Registers a chef/admin account (used from an internal admin setup flow).
  Future<UserModel> registerStaff({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = UserModel(
      userId: cred.user!.uid,
      name: name,
      email: email,
      role: role,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.userId)
        .set(user.toMap());
    return user;
  }

  Future<UserModel?> fetchProfile(String uid) async {
    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> signOut() => _auth.signOut();
}
