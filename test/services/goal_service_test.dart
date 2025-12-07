import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wallet_watch/services/goal_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GoalService service;
  const userId = "user_goal_heavy";

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = GoalService(firestore: fakeFirestore);
  });

  group('GOAL SERVICE — Comprehensive Suite', () {

    // Satisfies Product Feature 5 (Goals Tracking): "Users can create financial goals... with title."
    // Satisfies Section 2.2 (User Classes): "Add a new financial goal with a title and description."
    test('Add goal with target', () async {
      await service.addGoal(userId, {"title": "PS5", "target": 500.0, "saved": 0.0});
      final goals = await service.getGoals(userId);
      expect(goals.first["title"], "PS5");
    });

    // Validates Product Feature 5 (Firestore Integration): "Goals are saved under the user's Firestore document."
    // Ensures retrieval of multiple items (Data Persistence).
    test('Retrieve multiple goals', () async {
      await service.addGoal(userId, {"title": "A", "target": 100.0});
      await service.addGoal(userId, {"title": "B", "target": 200.0});
      final goals = await service.getGoals(userId);
      expect(goals.length, 2);
    });

    // Supports Section 1.1 (Purpose): "Track their progress toward financial objectives."
    // Validates logic required for the "Add and Manage Financial Goals" feature.
    test('Update goal: Add savings', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("goals").add({
        "title": "Bike", "saved": 100.0, "target": 500.0
      });

      await service.updateGoal(userId, ref.id, {"saved": 200.0});
      final doc = await ref.get();
      expect(doc["saved"], 200.0);
    });

    // Validates flexibility of "Manage Financial Goals" (Product Feature 5).
    // Allows users to adjust targets as financial situations change.
    test('Update goal: Change target', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("goals").add({
        "title": "House", "saved": 0.0, "target": 50000.0
      });

      // Market crash, houses are cheaper!
      await service.updateGoal(userId, ref.id, {"target": 40000.0});
      final doc = await ref.get();
      expect(doc["target"], 40000.0);
    });

    // Explicitly Satisfies Product Feature 5 (Goal Deletion): "Users can delete completed or irrelevant goals."
    // Satisfies Section 2.2 (User Classes): "View and delete existing financial goals."
    test('Delete goal removes it permanently', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("goals").add({
        "title": "Mistake"
      });

      await service.deleteGoal(userId, ref.id);

      final snap = await fakeFirestore.collection("users").doc(userId).collection("goals").get();
      expect(snap.docs.isEmpty, true);
    });


    // Validates the business logic for "Progress Visualization" mentioned in the Project Scope (Section 1.4).
    test('Verify goal completion status (Manual check)', () async {
      // Simulate app logic checking if a goal is done
      final ref = await fakeFirestore.collection("users").doc(userId).collection("goals").add({
        "title": "Phone", "saved": 999.0, "target": 1000.0
      });

      // User saves last dollar
      await service.updateGoal(userId, ref.id, {"saved": 1000.0});

      final doc = await ref.get();
      final isComplete = doc["saved"] >= doc["target"];
      expect(isComplete, true);
    });
  });
}