import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wallet_watch/services/loan_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late LoanService service;
  const userId = "user_loan_heavy";

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = LoanService(firestore: fakeFirestore);
  });

  group('LOAN SERVICE — Comprehensive Suite', () {

    // Satisfies Section 2.1 (Loans Module): "Add and track personal or external loans."
    // Satisfies Section 2.2 (Liabilities): "Add a new loan (title, amount...)."
    test('Create loan persists correctly', () async {
      await service.createLoan(userId, 5000.0);
      final snap = await fakeFirestore.collection("users").doc(userId).collection("loans").get();
      expect(snap.docs.length, 1);
      expect(snap.docs.first["total"], 5000.0);
      expect(snap.docs.first["paid"], 0.0);
    });

    // Validates Section 2.2 (Liabilities): "View all loans and their repayment progress."
    // Ensures the system can handle multiple liability entries simultaneously.
    test('Support multiple loans simultaneously', () async {
      await service.createLoan(userId, 1000.0);
      await service.createLoan(userId, 2000.0);

      final snap = await fakeFirestore.collection("users").doc(userId).collection("loans").get();
      expect(snap.docs.length, 2);
    });


    // Satisfies Section 2.2 (Liabilities): "Make a payment on an existing loan, which correctly updates the... amountPaid."
    test('Partial repayment updates balance', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 1000.0,
        "paid": 0.0
      });

      await service.repayLoan(userId, ref.id, 200.0);

      final doc = await ref.get();
      expect(doc["paid"], 200.0);
    });

    // Validates robustness of "Repayment Progress" (Section 2.2) to ensure cumulative math works.
    test('Multiple partial repayments sum up', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 1000.0,
        "paid": 0.0
      });

      await service.repayLoan(userId, ref.id, 200.0);
      await service.repayLoan(userId, ref.id, 300.0);

      final doc = await ref.get();
      expect(doc["paid"], 500.0);
    });

    // Validates logic for "Remaining Amount" calculation (Section 2.2).
    test('Exact repayment finishes loan', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 500.0,
        "paid": 400.0
      });

      await service.repayLoan(userId, ref.id, 100.0); // Exact match

      final doc = await ref.get();
      expect(doc["paid"], 500.0);
    });


    // Enforces NFR2.2 (Safety Requirements): "The system must ensure that financial calculations are accurate."
    test('Fail: Repayment amount cannot be zero', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 500.0, "paid": 0.0
      });

      expect(() => service.repayLoan(userId, ref.id, 0), throwsException);
    });

    test('Fail: Repayment amount cannot be negative', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 500.0, "paid": 0.0
      });

      expect(() => service.repayLoan(userId, ref.id, -50), throwsException);
    });

    // Validates Section 2.4 (Constraints): "All complex logic... must be performed on the client-side."
    // This test ensures the client logic prevents Paying > Owed (Business Rule).
    test('Fail: Overpayment not allowed', () async {
      final ref = await fakeFirestore.collection("users").doc(userId).collection("loans").add({
        "total": 100.0, "paid": 90.0
      });

      // Try to pay 20 (Remaining is only 10)
      expect(() => service.repayLoan(userId, ref.id, 20), throwsException);
    });
  });
}