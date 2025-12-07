import 'package:cloud_firestore/cloud_firestore.dart';

class LoanService {
  final FirebaseFirestore firestore;

  LoanService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createLoan(String userId, double totalAmount) async {
    await firestore
        .collection("users")
        .doc(userId)
        .collection("loans")
        .add({
      "total": totalAmount,
      "paid": 0,
    });
  }

  Future<void> repayLoan(String userId, String loanId, double amount) async {
    final doc = await firestore
        .collection("users")
        .doc(userId)
        .collection("loans")
        .doc(loanId)
        .get();

    final paid = doc["paid"];
    final total = doc["total"];

    if (amount <= 0) {
      throw Exception("Repayment must be > 0");
    }

    if (paid + amount > total) {
      throw Exception("Overpayment not allowed");
    }

    await firestore
        .collection("users")
        .doc(userId)
        .collection("loans")
        .doc(loanId)
        .update({
      "paid": paid + amount,
    });
  }
}
