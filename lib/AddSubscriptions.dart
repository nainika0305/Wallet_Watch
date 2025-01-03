import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Addsubscriptions extends StatefulWidget {
  const Addsubscriptions({super.key});

  @override
  State<Addsubscriptions> createState() => _AddsubscriptionsState();
}

class _AddsubscriptionsState extends State<Addsubscriptions> {

  final userId = FirebaseAuth.instance.currentUser!.email; //user id

  final TextEditingController _platformController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();

  // Add subscription to Firestore
  Future<void> _addSubscription() async {
    if (_platformController.text.isNotEmpty &&
        _amountController.text.isNotEmpty &&
        _startDateController.text.isNotEmpty) {
      final subscriptionData = {
        'platform': _platformController.text,
        'amount': double.parse(_amountController.text),
        'startDate': _selectedStartDate.toIso8601String(),
        'note': _noteController.text,
        // 'nextPaymentDate': _selectedStartDate
        // .add(const Duration(days: 30))
        //  .toIso8601String(), // Approximate next payment date
      };

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('Subscriptions').add(subscriptionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription added successfully')),
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
          double transactionAmount = double.tryParse(subscriptionData['amount'].toString()) ?? 0.0; // Safely parse to double

          totalMoney -= transactionAmount;

          // Update the totalMoney field in Firestore
          await docRef.update({'totalMoney': totalMoney}); // Use DocumentReference to update
          print("Total money after update: $totalMoney");
        } catch (e) {
          print("Error updating totalMoney: $e");
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add subscription: $e')),
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
    _platformController.clear();
    _amountController.clear();
    _startDateController.clear();
    _noteController.clear();
    _selectedStartDate = DateTime.now();
  }

  // Select subscription start date
  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
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
        title: const Text('Add New Subscription',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black,
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFFD1A7D1),
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
        padding: const EdgeInsets.all(19.0),
        child: Column(
          children: [
            // Form for adding subscription
            Card(
              elevation: 8,
              //color: Color(0xFFBDE0FE).withOpacity(0.65),
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(19.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),

                    const Text(
                      'Subscription Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003366), // Dark blue for contrast
                      ),
                    ),
                    const Divider(color: Color(0xFF003366)), // Divider color to match the theme
                    SizedBox(height: 16),

                    TextField(
                      controller: _platformController,
                      decoration: InputDecoration(
                        labelText: 'Platform (e.g., Netflix, Spotify)',
                        prefixIcon: const Icon(Icons.computer_rounded),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF003366),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFBDE0FE).withOpacity(0.3),
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
                        labelText: 'Monthly Amount',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF003366),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFBDE0FE).withOpacity(0.3),
                        prefixIcon: const Icon(Icons.money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),


                    TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF003366),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFBDE0FE).withOpacity(0.3),
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                        ),
                      ),
                      onTap: () => _selectStartDate(context),
                    ),
                    const SizedBox(height: 20),


                    TextField(
                      controller: _noteController,
                      style: TextStyle(
                        color: Colors.black87, // Set the text color here
                       fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Note (Optional)',
                        prefixIcon: const Icon(Icons.note),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF003366),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFBDE0FE).withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                        ),
                      ),

                    ),
                    const SizedBox(height: 20),

                    // add button

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA2D2FF),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Subscription',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003366),),
                        ),

                      ),

                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }
}

