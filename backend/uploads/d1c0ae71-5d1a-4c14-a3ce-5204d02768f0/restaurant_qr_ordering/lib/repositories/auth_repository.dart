import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Wraps AuthService so ViewModels never talk to FirebaseAuth directly.
class AuthRepository {
  final AuthService _authService;
  AuthRepository(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<User?> signInAnonymously() => _authService.signInAnonymously();

  Future<UserModel?> signInStaff(String email, String password) =>
      _authService.signInWithEmail(email, password);

  Future<UserModel> registerStaff({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) =>
      _authService.registerStaff(
        name: name,
        email: email,
        password: password,
        role: role,
      );

  Future<UserModel?> fetchProfile(String uid) => _authService.fetchProfile(uid);

  Future<void> signOut() => _authService.signOut();
}
