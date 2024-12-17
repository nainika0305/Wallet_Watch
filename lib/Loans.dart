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

  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTenureController = TextEditingController(); // in months
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _loanTitleController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();

  // Add loan to Firestore
  Future<void> _addLoan() async {

    if (_loanAmountController.text.isNotEmpty &&
        _interestRateController.text.isNotEmpty &&
        _loanTenureController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty)
    {
      final double loanAmount = double.parse(_loanAmountController.text);
      final int loanTenure = int.parse(_loanTenureController.text);

      final loanData = {
        'loan title': _loanTitleController,
        'loanAmount': loanAmount,
        'interestRate': double.parse(_interestRateController.text),
        'tenure': loanTenure,
        'startDate': _selectedStartDate.toIso8601String(),
        'notes': _notesController.text,
        'amountPaid': 0.0,
        'remainingAmount': loanAmount,
      };

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('Loans').add(loanData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan added successfully')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add loan: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  // Reset form fields
  void _resetForm() {
    _loanAmountController.clear();
    _interestRateController.clear();
    _loanTenureController.clear();
    _startDateController.clear();
    _notesController.clear();
    _selectedStartDate = DateTime.now();
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

  // Select Start Date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Loan Form
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Loan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    TextField(
                      controller: _loanTitleController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _loanAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Loan Amount',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _interestRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Interest Rate (%)',
                        prefixIcon: const Icon(Icons.percent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _loanTenureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Loan Tenure (in months)',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: const Icon(Icons.date_range),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onTap: () => _selectStartDate(context),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addLoan,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Loan', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Loan List
            const Text(
              'Your Loans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
      ),
    );
  }
}
