import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  // selected category is the category controller

  bool _isExpense = true;
  String? _selectedCategory;
  String? _modeOfPayment ;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _expenseCategories = [
    'Entertainment',
    'Dining',
    'Education',
    'Household Utilities',
    'Groceries',
    'Personal Grooming',
    'Travel',
    'Bills',
    'Electronics',
    'Medicines/Healthcare',
    'Others',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Other',
  ];

  // Reset form fields
  void _resetForm() {
    _amountController.clear();
    _titleController.clear();
    _noteController.clear();
    _dateController.clear();
    _timeController.clear();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = _selectedTime.format(context);
      });
    }
  }

  Widget _buildTransactionTypeButton(String title, bool isSelected, bool isExpense) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isExpense = isExpense;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? (isExpense ? Colors.lightBlue: Colors.purple ) : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true, // To fill the background with color
        fillColor: Color(0xFFFDA4BA).withOpacity(0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black,
          ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor:  Color(0xFFD1A7D1),
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

        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Toggle buttons for Expense and Income
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTransactionTypeButton('Expense', _isExpense, true),
                  const SizedBox(width: 16),
                  _buildTransactionTypeButton('Income', !_isExpense, false),
                ],
              ),
              const SizedBox(height: 20),


// Form Card with gradient
              Expanded(
                child: SingleChildScrollView(
                  /*decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFDBE9),
                        Color(0xFFE6D8FF), // Very light lavender
                        Color(0xFFBDE0FE), // Very light blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),*/
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),

                    ),
                    color: Colors.transparent, // Set the card color to transparent
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366), // Dark blue for contrast
                            ),
                          ),
                          const Divider(color: Color(0xFF003366)), // Divider color to match the theme
                          SizedBox(height: 10),
                          _buildFormField(
                            controller: _titleController,
                            label: 'Title',
                            icon: Icons.title,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            controller: _amountController,
                            label: 'Amount',
                            icon: Icons.money,
                            readOnly: false,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(

                            value: _selectedCategory,
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },

                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: Color(0xFF003366)), // Dark blue label
                              filled: true, // To fill the background with color
                              fillColor: Color(0xFFFDA4BA).withOpacity(0.35),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                              ),
                            ),
                            dropdownColor: Color(0xFFE6D8FF),

                            items: (_isExpense ? _expenseCategories : _incomeCategories)
                                .map((category) =>
                              DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              )
                            ).toList(),
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            controller: _dateController,
                            label: 'Date',
                            icon: Icons.calendar_today,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            controller: _timeController,
                            label: 'Time',
                            icon: Icons.access_time,
                            readOnly: true,
                            onTap: () => _selectTime(context),
                          ),
                          const SizedBox(height: 20),



                          DropdownButtonFormField<String>(
                            value: _modeOfPayment,
                            decoration: InputDecoration(
                              labelText: 'Payment Mode',
                              labelStyle: TextStyle(color: Color(0xFF003366)),
                              filled: true, // To fill the background with color
                              fillColor: Color(0xFFFDA4BA).withOpacity(0.35),// Dark blue label
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Color(0xFF003366), width: 1), // Added border color and width
                              ),
                            ),
                            dropdownColor: Color(0xFFEDD4FF),
                            items: ['UPI', 'Cash', 'Credit', 'Debit', 'Net Banking', 'Vouchers', 'Other']
                                .map((mode) {
                              return DropdownMenuItem<String>(
                                value: mode,
                                child: Text(mode),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _modeOfPayment = value!;
                              });
                            },
                            isExpanded: true,
                          ),
                          const SizedBox(height: 20),
                          _buildFormField(
                            controller: _noteController,
                            label: 'Note (Optional)',
                            icon: Icons.note,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),



              // Save Button, save to transactions
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final uniqueId = '${_titleController.text}_${DateTime.now().millisecondsSinceEpoch}';

                    if (_amountController.text.isNotEmpty && _titleController.text.isNotEmpty && _selectedCategory != null) {
                      final transactionData = {
                        'amount': double.parse(_amountController.text),
                        'category': _selectedCategory,
                        'date': Timestamp.fromDate(_selectedDate),
                        'time': _selectedTime.format(context),
                        'modeOfPayment': _modeOfPayment,
                        'title': _titleController.text,
                        'note': _noteController.text,
                        'type': _isExpense ? 'Expense' : 'Income',
                      };

                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final userId = user!.email; //user id
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('transactions')
                            .doc(uniqueId)
                            .set(transactionData);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaction added successfully')),
                        );
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
                            docRef.set({
                              'totalMoney': 0.00,
                            }, SetOptions(merge: true));
                            print("Document does not exist");
                          }
                          // Parse the transaction amount and type
                          double transactionAmount = double.tryParse(transactionData['amount'].toString()) ?? 0.0; // Safely parse to double
                          String transactionType = transactionData['type'] as String; // "Income" or "Expense"
                          // Adjust totalMoney based on the transaction type
                          if (transactionType == 'Income') {
                            totalMoney += transactionAmount; // Add for Income
                          } else if (transactionType == 'Expense') {
                            totalMoney -= transactionAmount; // Subtract for Expense
                          }
                          // Update the totalMoney field in Firestore
                          await docRef.update({'totalMoney': totalMoney}); // Use DocumentReference to update
                          // Print updated totalMoney for debugging
                          print("Total money after update: $totalMoney");
                        } catch (e) {
                          print("Error updating totalMoney: $e");
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add transaction: $e')),
                        );
                      }

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all the required fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:  Color(0xFFF699CD),
                  ),
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white
                    ),
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
