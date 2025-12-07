import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionService {
  final FirebaseFirestore firestore;

  TransactionService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Validate transaction before writing
  void _validateTransaction(Map<String, dynamic> data) {
    final amount = data["amount"];
    final type = data["type"];
    final category = data["category"];

    if (amount == null || amount <= 0) {
      throw ArgumentError("Amount must be positive.");
    }

    if (category == null || category.toString().trim().isEmpty) {
      throw ArgumentError("Category cannot be empty.");
    }

    if (type != "Income" && type != "Expense") {
      throw ArgumentError("Invalid transaction type.");
    }
  }

  /// Add a transaction to firestore
  Future<void> addTransaction(String userId, Map<String, dynamic> data) async {
    _validateTransaction(data);

    await firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .add(data);
  }

  /// Retrieve all user's transactions
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    final snap = await firestore
        .collection("users")
        .doc(userId)
        .collection("transactions")
        .get();

    return snap.docs.map((e) => e.data()).toList();
  }
}
