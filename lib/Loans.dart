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

                // Update Firestore with payment logic
                final updatedAmountPaid = (loanData['amountPaid'] as double) + paymentAmount;
                final updatedRemainingAmount =
                    (loanData['remainingAmount'] as double) - paymentAmount;

                try {
                  await loan.reference.update({
                    'amountPaid': updatedAmountPaid,
                    'remainingAmount': updatedRemainingAmount > 0 ? updatedRemainingAmount : 0,
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
        title: const Text('Loans'),
        centerTitle: true,
      ),
      body: Column(
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

                          title: Text('${data['loan title']}, Amount: ₹${data['loanAmount']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text('Remaining: ₹${data['remainingAmount']}'),
                              Text('Interest Rate: ${data['interestRate']}%'),
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
          ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addLoan');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
