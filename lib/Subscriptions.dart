import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {

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
        title: const Text('Manage Subscriptions'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form for adding subscription
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
                    const Text(
                      'Add New Subscription',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    TextField(
                      controller: _platformController,
                      decoration: InputDecoration(
                        labelText: 'Platform (e.g., Netflix, Spotify)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Monthly Amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () => _selectStartDate(context),
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

                    // add button

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSubscription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Subscription',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of subscriptions with progress bar
            const Text(
              'Your Subscriptions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance.collection('users').doc(userId).collection('Subscriptions').snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading subscriptions'));
                  }
                  final subscriptions = snapshot.data?.docs ?? [];
                  if (subscriptions.isEmpty) {
                    return const Center(child: Text('No subscriptions added yet.'));
                  }


                  return ListView.builder(
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = subscriptions[index];
                      final data = subscription.data() as Map<String, dynamic>;
                      final startDate = DateTime.parse(data['startDate']);
                      final currentDate = DateTime.now();

                      // Calculate the current billing cycle's start date
                      final currentCycleStart = DateTime(
                        currentDate.year,
                        currentDate.month,
                        startDate.day,
                      ).isBefore(currentDate)
                          ? DateTime(currentDate.year, currentDate.month, startDate.day)
                          : DateTime(currentDate.year, currentDate.month - 1, startDate.day);

                      // Calculate the next payment date for the current cycle
                      final nextPaymentDate = currentCycleStart.add(const Duration(days: 30));

                      // Calculate days remaining and progress
                      final daysRemaining = nextPaymentDate.difference(currentDate).inDays;
                      final progress = (currentDate.difference(currentCycleStart).inDays / 30).clamp(0.0, 1.0);


                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(data['platform']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amount: \$${data['amount']}'),
                              Text('Next Payment: ${DateFormat('yyyy-MM-dd').format(nextPaymentDate)}'),
                              Text('Days Remaining: ${daysRemaining > 0 ? daysRemaining : 0} '),
                              LinearProgressIndicator(
                                value: progress,
                                color: progress < 1.0 ? Colors.green : Colors.red, // Green for ongoing cycle, red for overdue
                                backgroundColor: Colors.grey[300],
                              ),

                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await subscription.reference.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Subscription deleted')),
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
      ),
    );
  }
}
