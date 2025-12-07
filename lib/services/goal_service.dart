import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final FirebaseFirestore firestore;

  GoalService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a new savings goal for the user
  Future<void> addGoal(String userId, Map<String, dynamic> goalData) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("goals")
        .add(goalData);
  }

  /// Retrieve all goals for a user
  Future<List<Map<String, dynamic>>> getGoals(String userId) async {
    final snapshot = await firestore
        .collection("users")
        .doc(userId)
        .collection("goals")
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Update goal progress or target
  Future<void> updateGoal(
      String userId, String goalId, Map<String, dynamic> updatedData) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("goals")
        .doc(goalId)
        .update(updatedData);
  }

  /// Delete a goal
  Future<void> deleteGoal(String userId, String goalId) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("goals")
        .doc(goalId)
        .delete();
  }
}
