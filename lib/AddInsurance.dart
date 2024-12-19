import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddInsurancePage extends StatefulWidget {
  const AddInsurancePage({super.key});

  @override
  State<AddInsurancePage> createState() => _AddInsurancePageState();
}

class _AddInsurancePageState extends State<AddInsurancePage> {
  // to save to database
  final userId = FirebaseAuth.instance.currentUser!.email; //user id


  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController =TextEditingController();

  DateTime _selectedDueDate = DateTime.now();

  // Add insurance policy to Firestore
  Future<void> _addInsurance() async {
    if (_providerController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _dueDateController.text.isNotEmpty &&
        _termController.text.isNotEmpty) {
      final insuranceData = {
        'title': _titleController.text,
        'provider': _providerController.text,
        'amount': double.parse(_amountController.text),
        'dueDate': _selectedDueDate.toIso8601String(),
        'term': _termController.text,
        'note': _noteController.text,
        'nextDueDate': _selectedDueDate.toIso8601String(),
      };

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('insurance').add(insuranceData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insurance policy added successfully')),
        );
        _resetForm();
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
          // Parse the transaction amount and type
          double transactionAmount = double.tryParse(insuranceData['amount'].toString()) ?? 0.0; // Safely parse to double

          totalMoney -= transactionAmount;
          // Update the totalMoney field in Firestore
          // Update the totalMoney field in Firestore
          await docRef.update({'totalMoney': totalMoney}); // Use DocumentReference to update

        } catch (e) {
          print("Error fetching total money: $e");
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add insurance policy: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the required fields')),
      );
    }
  }

  // Reset form fields
  void _resetForm() {
    _titleController.clear();
    _providerController.clear();
    _amountController.clear();
    _dueDateController.clear();
    _termController.clear();
    _noteController.clear();
    _selectedDueDate = DateTime.now();
  }

  // Select due date
  Future<void> _selectDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new insurance policy'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form for adding insurance policies
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _providerController,
                      decoration: InputDecoration(
                        labelText: 'Insurance Provider',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Premium Amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dueDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Next Due Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () => _selectDueDate(context),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _termController,
                      decoration: InputDecoration(
                        labelText: 'Policy Term (e.g., 1 year, 5 years)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addInsurance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Policy',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}