import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Loans extends StatefulWidget {
  const Loans({super.key});

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {

  final userId = FirebaseAuth.instance.currentUser!.email; //user id

  Future<void> _calculateInterest(DocumentSnapshot loan) async {
    final loanData = loan.data() as Map<String, dynamic>;
    final double interestRate = loanData['interestRate']; // Annual interest rate in percentage
    final double remainingAmount = loanData['remainingAmount'];

    // Calculate monthly interest
    final double monthlyInterest = remainingAmount * (interestRate / 100) / 12;

    // Update Firestore with the new interest
    await loan.reference.update({
      'accruedInterest': (loanData['accruedInterest'] as double) + monthlyInterest,
    });
  }



  @override
  void initState() {
    super.initState();
    _updateAllLoans();
  }

  Future<void> _updateAllLoans() async {
    final loansSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Loans')
        .get();

    for (final loan in loansSnapshot.docs) {
      await _calculateInterest(loan);
    }
  }


  // edit each transaton
  Future<void> _showPaymentDialog(BuildContext context, DocumentSnapshot loan) async {
    final TextEditingController paymentController = TextEditingController();
    final loanData = loan.data() as Map<String, dynamic>;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Make a Payment'),
          content: TextField(
            controller: paymentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Payment Amount',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final paymentAmount = double.tryParse(paymentController.text);
                if (paymentAmount == null || paymentAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid payment amount')),
                  );
                  return;
                }

                await _calculateInterest(loan); // Ensure interest is up-to-date


                // update the money u hacve paid, it is an expense
                try {
                  // Initialize the totalMoney to 0.0
                  double totalMoney = 0.0;
                  final docRef = FirebaseFirestore.instance.collection('users').doc(userId); // DocumentReference for the user
                  final doc = await docRef.get(); // Get the document snapshot

                  if (doc.exists) {
                    // Fetch current totalMoney, ensuring it's a double
                    totalMoney = (doc.data()?['totalMoney'] ?? 0.0).toDouble(); // Extract totalMoney from the doc
                    print("Total money before update: $totalMoney");
                  } else {
                    print("Document does not exist");
                  }
                  totalMoney -= paymentAmount;
                  // Update the totalMoney field in Firestore
                  await docRef.update({'totalMoney': totalMoney}); // Use DocumentReference to update
                  print("Total money after update: $totalMoney");
                } catch (e) {
                  print("Error updating totalMoney: $e");
                }

                final loanData = loan.data() as Map<String, dynamic>;
                double accruedInterest = loanData['accruedInterest'] as double;
                double remainingAmount = loanData['remainingAmount'] as double;

                // Allocate payment
                if (paymentAmount <= accruedInterest) {
                  accruedInterest -= paymentAmount;
                } else {
                  final principalPayment = paymentAmount - accruedInterest;
                  accruedInterest = 0.0;
                  remainingAmount -= principalPayment;
                }

                try {
                  await loan.reference.update({
                    'accruedInterest': accruedInterest,
                    'remainingAmount': remainingAmount > 0 ? remainingAmount : 0.0,
                    'amountPaid': (loanData['amountPaid'] as double) + paymentAmount,
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment successful')),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment failed: $e')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans',
          style: TextStyle(
            fontWeight: FontWeight.w600, // Make title bold
            color: Colors.black, // Lighter pink color
          ),),
        centerTitle: true,
        backgroundColor:  Color(0xFFD1A7D1).withOpacity(0.9),
      ),
      body: Container(
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [
          Color(0xFFFFDBE9),
          Color(0xFFE6D8FF), // Very light lavender
          Color(0xFFBDE0FE), // Very light blue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        ),
        ),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('Loans').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading loans.'));
                  }
                  final loans = snapshot.data?.docs ?? [];
                  if (loans.isEmpty) {
                    return const Center(child: Text('No loans added yet.'));
                  }
                  return ListView.builder(
                    itemCount: loans.length,
                    itemBuilder: (context, index) {
                      final loan = loans[index];
                      final data = loan.data() as Map<String, dynamic>;
                      final progress = data['amountPaid'] / data['loanAmount'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(

                          title: Text('${data['loanTitle']}, Amount: ₹${data['loanAmount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF281E5D), // Dark blue for contrast
                              )
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Interest Rate: ${data['interestRate']}% for ${data['tenure']} months'),
                              Text('Interest per month: ₹${data['InterestPerMonth'].toString()}'),
                              Text('Remaining: ₹${data['remainingAmount']}'),
                              Text('Paid: ₹${data['amountPaid']}'),
                              if (data['notes'] != null && data['notes'].isNotEmpty)
                                Text('Note: ${data['notes']}'),

                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                color: Colors.green,
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.payment, color: Colors.blue),
                            tooltip: 'Make a Payment',
                            onPressed: () => _showPaymentDialog(context, loan),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addLoan');
                  },
                  icon: Icon(Icons.add, color: Colors.white,),
                  label: Text('Add loan',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 17,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:  Color(0xFF2832C2).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
      ),
      ),

    );
  }
}
