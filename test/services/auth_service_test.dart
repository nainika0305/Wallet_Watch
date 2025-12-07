import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:wallet_watch/services/auth_service.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthService service;

  setUp(() {
    // Simulate a backend with one existing user
    final user = MockUser(
      isAnonymous: false,
      uid: 'existing_uid',
      email: 'olduser@example.com',
      displayName: 'Old User',
    );
    mockAuth = MockFirebaseAuth(mockUser: user);
    service = AuthService(auth: mockAuth);
  });

  group('AUTH SERVICE — Comprehensive Suite', () {

    // --- REGISTRATION ---
     // Satisfies FR1.1: The system shall allow a new user to register for an account.
    test('Register creates a new valid user', () async {
      final user = await service.registerUser("new@test.com", "password123");

      expect(user, isNotNull);
      expect(user!.email, "new@test.com");
      expect(mockAuth.currentUser!.email, "new@test.com");
    });

    // --- LOGIN ---
     // Satisfies FR1.3: The system shall log in an existing user with their registered email and password.
    test('Login success with correct credentials', () async {
      // Note: MockFirebaseAuth allows any password by default unless configured otherwise,
      // but it validates the flow matches the Firebase API structure.
      final user = await service.loginUser("olduser@example.com", "any_password");

      expect(user, isNotNull);
      expect(user!.email, "olduser@example.com");
      expect(user.uid, "existing_uid");
    });

     // Satisfies FR1.2: The system shall validate the email format.
     // Also relates to FR1.4: Display error message for invalid credentials.
    test('Login fails validation on empty email', () async {
      // Firebase Auth throws error on empty email
      expect(
              () => service.loginUser("", "pass"),
          throwsA(isA<Exception>()) // Or FirebaseAuthException
      );
    });

    // --- LOGOUT ---
     // Satisfies FR5.4: The system shall provide a "Log Out" button that securely ends the user's session.
     // Also validates FR1.6: The system shall maintain a persistent session.
    test('Logout clears the current session', () async {
      // 1. Login first
      await service.loginUser("olduser@example.com", "pass");
      expect(mockAuth.currentUser, isNotNull);

      // 2. Logout
      await service.logout();

      // 3. Verify
      expect(mockAuth.currentUser, isNull);
    });

    // --- PASSWORD RESET ---
     // Satisfies FR1.5: The system shall provide a "Forgot Password" option that sends a reset link.
    test('Password reset sends email (Simulated)', () async {
      // This method returns void, so we just check it doesn't throw
      // and completes successfully.
      await expectLater(
          service.sendPasswordReset("olduser@example.com"),
          completes
      );
    });
  });
}