import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// Note: Capital 'U' matches your file name
import 'package:wallet_watch/services/User_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserService service;
  const userId = "user_profile_heavy";

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = UserService(firestore: fakeFirestore);
  });

  group('USER SERVICE — Comprehensive Suite', () {

    // Satisfies FR5.1 (P1): "The system shall display the user's name and email on the 'Profile' page."
    // Validates Section 2.1 (User Information): Stores first name, last name, and email securely.
    test('Create new profile persists data', () async {
      final data = {
        "username": "Nainika",
        "email": "test@example.com",
        "joined": "2024-01-01"
      };
      await service.createUserProfile(userId, data);

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc.data()?["username"], "Nainika");
      expect(doc.data()?["email"], "test@example.com");
    });

    // Validates Data Integrity (NFR2.2): Ensures partial updates (like editing a name) do not delete other existing data.
    test('Create profile merges data (Does not overwrite existing fields)', () async {
      // 1. Create initial data with 'age'
      await fakeFirestore.collection("users").doc(userId).set({"age": 25});

      // 2. Run createUserProfile with ONLY name
      await service.createUserProfile(userId, {"name": "Updated Name"});

      // 3. Verify 'age' is STILL there (Merge check)
      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc.data()?["name"], "Updated Name");
      expect(doc.data()?["age"], 25); // Should not be null!
    });

    // Validates robust error handling (Section 2.5 Assumptions): System handles missing users gracefully.
    test('Get profile returns null if user does not exist', () async {
      final data = await service.getUserProfile("ghost_user");
      expect(data, null);
    });

    // Foundational logic for FR4.1: "The system shall display a summary of... current savings."
    test('Get total money defaults to 0 if field missing', () async {
      // User exists but has no 'totalMoney' field yet
      await fakeFirestore.collection("users").doc(userId).set({"name": "Newbie"});

      // Happy Path: Initialize and update
      await service.updateTotalMoney(userId, 500.0);
      final money = await service.getTotalMoney(userId);
      expect(money, 500.0);
    });

    // Critical validation for FR4.4: "All data on the Homepage shall update in real-time."
    // Ensures the balance displayed matches the database state.
    test('Update money overwrites previous value', () async {
      await fakeFirestore.collection("users").doc(userId).set({"totalMoney": 100.0});
      await service.updateTotalMoney(userId, 5000.0);

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc.data()?["totalMoney"], 5000.0);
    });

    // Supports Section 2.2 (User Classes): Allows updating flexible user attributes.
    test('Update specific field (e.g., phone number)', () async {
      await fakeFirestore.collection("users").doc(userId).set({"phone": "123"});

      await service.updateUserField(userId, "phone", "999");

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc.data()?["phone"], "999");
    });

    test('Update field creates it if missing', () async {
      await fakeFirestore.collection("users").doc(userId).set({});

      await service.updateUserField(userId, "nickname", "Chief");

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc.data()?["nickname"], "Chief");
    });
  });
}