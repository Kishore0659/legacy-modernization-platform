import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, unauthenticated, customer, staff }

/// Handles both the anonymous customer flow and the chef/admin login flow.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  AuthViewModel(this._repository) {
    _init();
  }

  AuthStatus status = AuthStatus.unknown;
  UserModel? staffProfile;
  bool isLoading = false;
  String? errorMessage;

  void _init() {
    _repository.authStateChanges.listen((user) async {
      if (user == null) {
        status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      if (user.isAnonymous) {
        status = AuthStatus.customer;
        notifyListeners();
        return;
      }
      final profile = await _repository.fetchProfile(user.uid);
      staffProfile = profile;
      status = AuthStatus.staff;
      notifyListeners();
    });
  }

  Future<void> ensureCustomerSignedIn() async {
    await _repository.signInAnonymously();
  }

  Future<bool> loginStaff(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final profile = await _repository.signInStaff(email, password);
      staffProfile = profile;
      isLoading = false;
      status = AuthStatus.staff;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool get isChef => staffProfile?.role == UserRole.chef;
  bool get isAdmin => staffProfile?.role == UserRole.admin;

  Future<void> logout() async {
    await _repository.signOut();
    staffProfile = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
