// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;

  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  /// Register new user
  Future<User?> registerUser(String email, String password) async {
    //  Input Validation
    if (email.isEmpty) throw Exception("Email cannot be empty");
    if (password.length < 6) throw Exception("Password must be at least 6 characters");

    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Login user
  Future<User?> loginUser(String email, String password) async {
    if (email.isEmpty) throw Exception("Email cannot be empty");
    if (password.isEmpty) throw Exception("Password cannot be empty");

    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    if (email.isEmpty) throw Exception("Email cannot be empty");
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}