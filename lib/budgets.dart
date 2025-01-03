import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_budget_page.dart';

class Budgets extends StatefulWidget {
  const Budgets({super.key});

  @override
  State<Budgets> createState() => _BudgetsState();
}

class _BudgetsState extends State<Budgets> {
  String? userId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid;
  }

  Future<void> _allocateFunds(String budgetId, double amount, String type) async {
    final budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId);

    try {
      final budgetSnapshot = await budgetRef.get();
      if (!budgetSnapshot.exists) return;

      final data = budgetSnapshot.data() ?? {};
      double currentAmount = type == 'expense'
          ? (data['spending'] ?? 0.0) as double
          : (data['allocation'] ?? 0.0) as double;

      currentAmount += amount;

      await budgetRef.update(
        type == 'expense'
            ? {'spending': currentAmount}
            : {'allocation': currentAmount},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funds allocated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Center(
        child: Text('User not logged in.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make title bold
            color: Colors.black, // Lighter pink color
          ),),
        automaticallyImplyLeading: false,
        elevation: 4.0,
        backgroundColor: Color(0xFFD1A7D1), // Soft lavender
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('budgets')
                    .where('type', isEqualTo: 'expense')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No expense budgets added.'));
                  }

                  final budgets = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      final budgetId = budget.id;
                      final data = budget.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unnamed';
                      final amount = (data['amount'] ?? 0.0) as double;
                      final spending = (data['spending'] ?? 0.0) as double;
                      final timeline = data['timeline'] ?? 'No timeline';
                      final color = data['colorTag'] != null
                          ? Color(int.parse(data['colorTag']))
                          : Color(0xFFBDE0FE); // Sky blue

                      return BudgetItem(
                        name: name,
                        amount: amount,
                        progress: spending / amount,
                        timeline: timeline,
                        color: color,
                        onAllocate: (amount) {
                          _allocateFunds(budgetId, amount, 'expense');
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(
              thickness: 4,
              color: Colors.black54,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('budgets')
                    .where('type', isEqualTo: 'savings')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No savings budgets added.'));
                  }

                  final budgets = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      final budgetId = budget.id;
                      final data = budget.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unnamed';
                      final amount = (data['amount'] ?? 0.0) as double;
                      final allocation = (data['allocation'] ?? 0.0) as double;
                      final timeline = data['timeline'] ?? 'No timeline';
                      final color = data['colorTag'] != null
                          ? Color(int.parse(data['colorTag']))
                          : Color(0xFFA2D2FF); // Periwinkle blue

                      return BudgetItem(
                        name: name,
                        amount: amount,
                        progress: allocation / amount,
                        timeline: timeline,
                        color: color,
                        onAllocate: (amount) {
                          _allocateFunds(budgetId, amount, 'savings');
                        },
                      );
                    },
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddBudgetPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: Color(0xFFFFDBE9).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),

                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color:Color(0xFF2832C2), size: 30),
                    SizedBox(width: 10),
                    Text(
                      "Add Budget",
                       style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF2832C2), // Dark blue for contrast
                    ),
                    ),
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

class BudgetItem extends StatelessWidget {
  final String name;
  final double amount;
  final double progress;
  final String timeline;
  final Color color;
  final void Function(double) onAllocate;

  const BudgetItem({
    super.key,
    required this.name,
    required this.amount,
    required this.progress,
    required this.timeline,
    required this.color,
    required this.onAllocate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: ListTile(
        title: Text(name,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF281E5D), // Dark blue for contrast
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline: $timeline'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: color,
            ),
            const SizedBox(height: 8),
            Text('Progress: \₹${(progress * amount).toStringAsFixed(2)} of \₹${amount.toStringAsFixed(2)}'),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Allocate Funds'),
                      content: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount to allocate',
                        ),
                        onSubmitted: (value) {
                          double allocatedAmount = double.tryParse(value) ?? 0.0;
                          if (allocatedAmount > 0) {
                            onAllocate(allocatedAmount);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              child: const Text('Allocate Funds'),
            ),
          ],
        ),
      ),
    );
  }
}
