import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetService {
  final FirebaseFirestore firestore;

  BudgetService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Set a user's budget limit
  Future<void> setBudget(String userId, double limit) async {
    await firestore.collection("users").doc(userId).update({
      "budgetLimit": limit,
    });
  }

  /// Get current budget limit
  Future<double?> getBudget(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    return doc.data()?["budgetLimit"] as double?;
  }

  /// Add spent amount
  Future<void> addToSpent(String userId, double amount) async {
    final doc = await firestore.collection("users").doc(userId).get();
    double currentSpent = (doc.data()?["spent"] ?? 0).toDouble();

    await firestore.collection("users").doc(userId).update({
      "spent": currentSpent + amount,
    });
  }

  /// Reset remaining spent for testing or app design
  Future<void> resetSpent(String userId) async {
    await firestore.collection("users").doc(userId).update({
      "spent": 0,
    });
  }
}
