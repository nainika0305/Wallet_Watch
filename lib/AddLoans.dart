import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddLoansPage extends StatefulWidget {
  const AddLoansPage({super.key});

  @override
  State<AddLoansPage> createState() => _AddLoansPageState();
}

class _AddLoansPageState extends State<AddLoansPage> {
  final userId = FirebaseAuth.instance.currentUser!.email;

  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _loanTenureController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _loanTitleController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();

  Future<void> _addLoan() async {
    if (_loanAmountController.text.isNotEmpty &&
        _interestRateController.text.isNotEmpty &&
        _loanTenureController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty) {
      final double loanAmount = double.parse(_loanAmountController.text);
      final double interestRate = double.parse(_interestRateController.text) / 100;
      final int loanTenure = int.parse(_loanTenureController.text);

      final loanData = {
        'loanTitle': _loanTitleController.text,
        'loanAmount': loanAmount,
        'interestRate': interestRate,
        'tenure': loanTenure,
        'startDate': _selectedStartDate.toIso8601String(),
        'notes': _notesController.text,
        'amountPaid': 0.0,
        'remainingAmount': loanAmount,
        'accruedInterest': 0.0,
        'lastInterestCalculationDate': DateTime.now().toIso8601String(),
        'InterestPerMonth': (double.parse(_loanAmountController.text) * double.parse(_interestRateController.text))/(loanTenure*100),
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('Loans')
            .add(loanData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan added successfully')),
        );
        _resetForm();
        Navigator.pop(context);
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

  void _resetForm() {
    _loanAmountController.clear();
    _interestRateController.clear();
    _loanTenureController.clear();
    _startDateController.clear();
    _notesController.clear();
    _selectedStartDate = DateTime.now();
  }

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
        title: const Text('Add New Loan',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black, // Lighter pink color
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor:Color(0xFF3B8EF3),
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
      child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 8,
              color: Color(0xFFBDE0FE).withOpacity(0.65),
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
                      'Loan Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366), // Dark blue for contrast
                      ),
                    ),
                    const Divider(color: Color(0xFF003366)), // Divider color to match the theme
                    SizedBox(height: 16),

                    TextField(
                      controller: _loanTitleController,
                      keyboardType: TextInputType.text,
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
                      controller: _loanAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Loan Amount',
                        prefixIcon: const Icon(Icons.money),
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
                      controller: _interestRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Interest Rate (%) per annum',
                        prefixIcon: const Icon(Icons.percent_rounded),
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
                      controller: _loanTenureController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Loan Tenure (in months)',
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
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: const Icon(Icons.calendar_month),
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
                      onTap: () => _selectStartDate(context),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
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
                        onPressed: _addLoan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B8EF3),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Add Loan', style: TextStyle(fontSize: 19,color: Colors.white), ),
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
