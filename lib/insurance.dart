import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Insurance extends StatefulWidget {
  const Insurance({super.key});

  @override
  State<Insurance> createState() => _InsuranceState();
}

class _InsuranceState extends State<Insurance> {

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
        await FirebaseFirestore.instance.collection('insurance').add(insuranceData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insurance policy added successfully')),
        );
        _resetForm();
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
        title: const Text('Insurance Policies'),
        centerTitle: true,
        elevation: 0,
      ),
            body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
       
            const Divider(),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('insurance').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading policies'));
                  }
                  final policies = snapshot.data?.docs ?? [];
                  if (policies.isEmpty) {
                    return const Center(child: Text('No insurance policies added yet.'));
                  }
                  return ListView.builder(
                    itemCount: policies.length,
                    itemBuilder: (context, index) {
                      final policy = policies[index];
                      final data = policy.data() as Map<String, dynamic>;
                      final nextDueDate = DateTime.parse(data['nextDueDate']);
                      final daysRemaining = nextDueDate.difference(DateTime.now()).inDays;
                      final progress = 1 - (daysRemaining / 30);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('${data['title']}, ${data['provider']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: \₹${data['amount']}'),
                              Text('Next Due Date: ${DateFormat('yyyy-MM-dd').format(nextDueDate)}'),
                              Text('Days Remaining: ${daysRemaining > 0 ? daysRemaining : 0}'),
                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                color: daysRemaining > 0 ? Colors.green : Colors.red,
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await policy.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Policy deleted')),
                              );
                            },
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
          Navigator.pushNamed(context, '/addInsurance');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
