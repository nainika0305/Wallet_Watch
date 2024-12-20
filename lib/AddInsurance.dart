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
  final userId = FirebaseAuth.instance.currentUser!.email;

  final TextEditingController _providerController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _termController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  DateTime _selectedDueDate = DateTime.now();

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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('insurance')
            .add(insuranceData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insurance policy added successfully')),
        );
        _resetForm();

        try {
          double totalMoney = 0.0;
          final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
          final doc = await docRef.get();

          if (doc.exists) {
            totalMoney = (doc.data()?['totalMoney'] ?? 0.0).toDouble();
          }

          double transactionAmount =
              double.tryParse(insuranceData['amount'].toString()) ?? 0.0;

          totalMoney -= transactionAmount;

          await docRef.update({'totalMoney': totalMoney});
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

  void _resetForm() {
    _titleController.clear();
    _providerController.clear();
    _amountController.clear();
    _dueDateController.clear();
    _termController.clear();
    _noteController.clear();
    _selectedDueDate = DateTime.now();
  }

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
        title: const Text('Add Insurance Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black,
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF3B8EF3).withOpacity(0.9),
      ),
      body: Container(
        decoration: const BoxDecoration(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                color: Color(0xFFBDE0FE).withOpacity(0.8),
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(19.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Policy Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003366), // Dark blue for contrast
                        ),
                      ),
                      const Divider(color: Color(0xFF003366)), // Divider color to match the theme
                      SizedBox(height: 16),

                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          prefixIcon: const Icon(Icons.title),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _providerController,
                        decoration: InputDecoration(
                          labelText: 'Insurance Provider',
                          prefixIcon: const Icon(Icons.computer ),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Premium Amount',
                          prefixIcon: const Icon(Icons.attach_money),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _dueDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Next Due Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                        onTap: () => _selectDueDate(context),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _termController,
                        decoration: InputDecoration(
                          labelText: 'Policy Term (e.g., 1 year, 5 years)',
                          prefixIcon: const Icon(Icons.timer),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)',
                          prefixIcon: const Icon(Icons.note),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003366),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFFF4F2).withOpacity(0.7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addInsurance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B8EF3),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Policy',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
