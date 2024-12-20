import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategory;
  Color _selectedColor = Color(0xFFCDB4DB); // Default to lavender color

  bool isExpenseBudget = true;

  final List<String> _categories = [
    'Car',
    'Home',
    'Travel',
    'Health',
    'Groceries',
    'Entertainment',
    'Savings',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
        centerTitle: true,
        backgroundColor: Color(0xFFCDB4DB), // Lavender
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Expense/Savings Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBudgetTypeButton('Expense Budget', isExpenseBudget, true, Color(0xFFBDE0FE)),
                const SizedBox(width: 16),
                _buildBudgetTypeButton('Savings Budget', !isExpenseBudget, false, Color(0xFFFAF9F5)),
              ],
            ),
            const SizedBox(height: 20),

            // Form Fields
            Expanded(
              child: ListView(
                children: [
                  _buildFormField(
                    controller: _nameController,
                    label: 'Budget Name',
                    icon: Icons.edit,
                    color: Color(0xFFCDB4DB),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _timelineController,
                    label: 'Timeline (e.g., 3 months)',
                    icon: Icons.timer,
                    color: Color(0xFFFAF9F5),
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _amountController,
                    label: 'Budget Amount',
                    icon: Icons.attach_money,
                    color: Color(0xFFFAF9F5),
                  ),
                  const SizedBox(height: 16),
                  _buildColorPicker(),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                ],
              ),
            ),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFAFCC), // Rose pink
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTypeButton(String title, bool isActive, bool setExpense, Color activeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpenseBudget = setExpense;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(borderSide: BorderSide(color: color)),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pick a Color',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        GestureDetector(
          onTap: _showColorPicker,
          child: CircleAvatar(
            backgroundColor: _selectedColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      items: _categories
          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      decoration: const InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBudget() async {
    final name = _nameController.text.trim();
    final timeline = _timelineController.text.trim();
    final category = _selectedCategory;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (name.isEmpty || timeline.isEmpty || category == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid data')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final budgetData = {
      'name': name,
      'timeline': timeline,
      'category': category,
      'colorTag': _selectedColor.value.toString(),
      'progress': 0.0,
      'amount': amount,
      'type': isExpenseBudget ? 'expense' : 'savings',
      'spending': 0.0,  // Initialize spending for expense budgets
      'allocation': 0.0,  // Initialize allocation for savings budgets
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .add(budgetData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
