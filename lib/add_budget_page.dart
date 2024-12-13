import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _otherCategoryController = TextEditingController();

  String? _selectedCategory;
  Color _selectedColor = Colors.blue;

  bool isExpenseBudget = true;
  bool isOtherCategorySelected = false;

  final List<String> _categories = [
    'Car', 'Home', 'Travel', 'Health', 'Groceries', 'Entertainment',
    'Utilities', 'Education', 'Dining Out', 'Shopping', 'Savings',
    'Insurance', 'Investments', 'Gifts', 'Charity', 'Childcare',
    'Pet Care', 'Fitness', 'Subscriptions', 'Miscellaneous', 'Other',
    'Other Category 1', 'Other Category 2', 'Other Category 3', // Additional categories for testing
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Toggle buttons for Expense and Savings
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBudgetTypeButton('Expense Budget', isExpenseBudget, true),
                const SizedBox(width: 16),
                _buildBudgetTypeButton('Savings Budget', !isExpenseBudget, false),
              ],
            ),
            const SizedBox(height: 20),

            // Form Card
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        _buildFormField(
                          controller: _nameController,
                          label: 'Budget Name',
                          icon: Icons.edit,
                        ),
                        const SizedBox(height: 16),
                        _buildFormField(
                          controller: _timelineController,
                          label: 'Timeline (e.g., 6 months)',
                          icon: Icons.timer,
                        ),
                        const SizedBox(height: 16),
                        _buildColorPicker(),
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                        if (isOtherCategorySelected) ...[
                          const SizedBox(height: 16),
                          _buildFormField(
                            controller: _otherCategoryController,
                            label: 'Enter Category',
                            icon: Icons.category,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Save Button
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green,
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
                child: const Text(
                  'Save Budget',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Budget Type Toggle Button
  ElevatedButton _buildBudgetTypeButton(String title, bool isSelected, bool setToExpense) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isExpenseBudget = setToExpense;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? (setToExpense ? Colors.blue : Colors.green) : Colors.grey,
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

  // Form Field Builder
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Color Picker
  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Color:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _showColorPicker(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  // Category Dropdown
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: const Text('Select Category'),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
          isOtherCategorySelected = value == 'Other';
        });
      },
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      isExpanded: true, // Ensures dropdown uses all available space
      isDense: true,
      menuMaxHeight: 400, // Set the max height for the dropdown (scrollable area)
    );
  }

  // Show Color Picker Dialog
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBudget() async {
    final name = _nameController.text.trim();
    final timeline = _timelineController.text.trim();
    final category = isOtherCategorySelected
        ? _otherCategoryController.text.trim()
        : _selectedCategory;

    if (name.isEmpty || timeline.isEmpty || category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
      return;
    }

    final userId = 'userId'; // Replace with actual user ID
    final collection = isExpenseBudget ? 'expenses' : 'savings';

    final budgetData = {
      'name': name,
      'timeline': timeline,
      'category': category,
      'colorTag': _selectedColor.value.toString(),
      'progress': 0.0,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collection)
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
