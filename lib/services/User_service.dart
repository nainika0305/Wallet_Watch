import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore firestore;

  UserService({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  /// Create initial user profile when user registers
  Future<void> createUserProfile(String userId, Map<String, dynamic> data) async {
    await firestore.collection("users").doc(userId).set(data, SetOptions(merge: true));
  }

  /// Retrieve user profile details
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    return doc.data();
  }

  /// Update wallet balance (total money)
  Future<void> updateTotalMoney(String userId, double amount) async {
    await firestore.collection("users").doc(userId).update({
      "totalMoney": amount,
    });
  }

  Future<double> getTotalMoney(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    return doc["totalMoney"] as double;
  }

  /// Generic update for any field (ex: username, phone, etc.)
  Future<void> updateUserField(String userId, String field, dynamic value) async {
    await firestore.collection("users").doc(userId).update({
      field: value,
    });
  }
}
