import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wallet_watch/services/budget_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BudgetService service;
  const userId = "user_budget_heavy";

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = BudgetService(firestore: fakeFirestore);
  });

  group('BUDGET SERVICE — Comprehensive Suite', () {

    // Satisfies FR3.1: The system shall allow a user to create a new monthly budget.
    test('Set initial budget', () async {
      await fakeFirestore.collection("users").doc(userId).set({}); // Pre-create
      await service.setBudget(userId, 2000.0);
      expect(await service.getBudget(userId), 2000.0);
    });

    // Validates FR3.1: Ensures budget values can be modified/overwritten.
    test('Update existing budget (increase)', () async {
      await fakeFirestore.collection("users").doc(userId).set({"budgetLimit": 2000.0});
      await service.setBudget(userId, 5000.0);
      expect(await service.getBudget(userId), 5000.0);
    });

    test('Update existing budget (decrease)', () async {
      await fakeFirestore.collection("users").doc(userId).set({"budgetLimit": 5000.0});
      await service.setBudget(userId, 1000.0);
      expect(await service.getBudget(userId), 1000.0);
    });

    // Foundation for FR3.3: The system shall display a progress bar showing amount spent vs allocated.
    // This test ensures the 'spent' value is accurately tracked in the database.
    test('Add spending to empty account', () async {
      await fakeFirestore.collection("users").doc(userId).set({"spent": 0.0});
      await service.addToSpent(userId, 50.0);

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc["spent"], 50.0);
    });

    // Validates FR3.3: Ensures cumulative spending is calculated correctly for the progress bar.
    test('Add spending cumulatively (50 + 20 + 10)', () async {
      await fakeFirestore.collection("users").doc(userId).set({"spent": 50.0});
      await service.addToSpent(userId, 20.0);
      await service.addToSpent(userId, 10.0);

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc["spent"], 80.0);
    });

    // Satisfies FR3.4: The system shall calculate and display the... overspent amount.
    // Validates FR3.14: Alerts when spending nears or exceeds the set budget limit (Data foundation).
    test('Spending can exceed budget (Logic check)', () async {
      // System should track it even if it goes over
      await fakeFirestore.collection("users").doc(userId).set({
        "budgetLimit": 100.0,
        "spent": 90.0
      });

      await service.addToSpent(userId, 20.0); // Total 110

      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc["spent"], 110.0);
      expect(doc["spent"] > doc["budgetLimit"], true);
    });

    // Helper function for maintaining FR3.2 (Active Budgets) validity at start of new month.
    test('Reset spent clears debt completely', () async {
      await fakeFirestore.collection("users").doc(userId).set({"spent": 12345.67});
      await service.resetSpent(userId);
      final doc = await fakeFirestore.collection("users").doc(userId).get();
      expect(doc["spent"], 0.0);
    });

    // Validates FR3.2: The system shall display all active budgets (Handles null/empty states).
    test('Get budget returns null if not set', () async {
      await fakeFirestore.collection("users").doc(userId).set({}); // No budget field
      final val = await service.getBudget(userId);
      expect(val, null);
    });
  });
}