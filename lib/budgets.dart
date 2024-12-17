import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_budget_page.dart';

// Entry point for the Budgets page, which displays expense and savings budgets.
class Budgets extends StatefulWidget {
  const Budgets({super.key});

  @override
  State<Budgets> createState() => _BudgetsState();
}

// The stateful widget for managing budgets.
class _BudgetsState extends State<Budgets> {
  String? userId;
  // To store the current user's ID.

  @override
  void initState() {
    super.initState();
    // Fetch the currently signed-in user's information when the widget is initialized.
    final currentUser = FirebaseAuth.instance.currentUser;
    userId = currentUser?.uid;
    // Assign the user's unique ID if logged in.
  }

  // Function to allocate funds to a specific budget (either for spending or savings).
  Future<void> _allocateFunds(String budgetId, double amount, String type) async {
    // Reference to the Firestore document for the selected budget.
    final budgetRef = FirebaseFirestore.instance
        .collection('users')
    // Access the 'users' collection.
        .doc(userId)
    // Access the document for the currently signed-in user.
        .collection('budgets')
    // Access the 'budgets' subcollection.
        .doc(budgetId);
    // Access the specific budget document.

    try {
      // Retrieve the budget document snapshot from Firestore.
      final budgetSnapshot = await budgetRef.get();
      if (!budgetSnapshot.exists) return; // If document doesn't exist, exit the function.

      // Extract the data from the document snapshot.
      final data = budgetSnapshot.data() ?? {};

      // Determine the current amount based on the budget type (expense or savings).
      double currentAmount = type == 'expense'
          ? (data['spending'] ?? 0.0) as double
          : (data['allocation'] ?? 0.0) as double;

      // Increment the current amount by the allocated amount.
      currentAmount += amount;

      // Update the Firestore document with the new amount based on the type.
      await budgetRef.update(
        type == 'expense'
            ? {'spending': currentAmount} // Update the 'spending' field.
            : {'allocation': currentAmount}, // Update the 'allocation' field.
      );

      // Show a success message when funds are successfully allocated.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Funds allocated successfully!')),
      );
    } catch (e) {
      // Handle and display any errors that occur during the allocation process.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')), // Show the error message.
      );
    }
  }

  // Build method to define the UI of the Budgets page.
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in before rendering the UI.
    if (userId == null) {
      // If no user is logged in, display a message.
      return const Center(
        child: Text('User not logged in.'), // Inform the user about the login status.
      );
    }

    // Define the Scaffold for the Budgets page.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        // Title for the AppBar.
        automaticallyImplyLeading: false,
        // Prevents back navigation by default.
        centerTitle: true,
        // Centers the title in the AppBar.
        elevation: 4.0,
        // Adds a shadow effect to the AppBar.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body content.
        child: Column(
          children: [
            // Section for Expense Budgets
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Stream data for expense budgets from Firestore.
                stream: FirebaseFirestore.instance
                    .collection('users')
                // Access the 'users' collection.
                    .doc(userId)
                // Access the current user's document.
                    .collection('budgets')
                // Access the 'budgets' subcollection.
                    .where('type', isEqualTo: 'expense')
                // Filter for expense budgets.
                    .snapshots(),
                // Listen for real-time updates.

                builder: (context, snapshot) {
                  // Check the connection state of the snapshot.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show a loading indicator while waiting for data.
                    return const Center(child: CircularProgressIndicator());
                  }

                  // If no data or documents exist, display a placeholder message.
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No expense budgets added.'));
                  }

                  // Retrieve the list of budgets from the snapshot.
                  final budgets = snapshot.data!.docs;

                  // Build a ListView to display the budgets.
                  return ListView.builder(
                    // Number of items in the list.
                    itemCount: budgets.length,
                    itemBuilder: (context, index) {
                      // Get the specific budget document.
                      final budget = budgets[index];
                      // Get the budget's ID.
                      final budgetId = budget.id;
                      // Extract the budget data.
                      final data = budget.data() as Map<String, dynamic>;
                      // Get the budget's name.
                      final name = data['name'] ?? 'Unnamed';
                      // Get the total amount.
                      final amount = (data['amount'] ?? 0.0) as double;
                      // Get the spending so far.
                      final spending = (data['spending'] ?? 0.0) as double;
                      // Get the timeline.
                      final timeline = data['timeline'] ?? 'No timeline';
                      // Determine the color for the budget.
                      final color = data['colorTag'] != null
                          ? Color(int.parse(data['colorTag']))
                          : Colors.blue;

                      // Return a BudgetItem widget for each budget.
                      return BudgetItem(
                        // Name of the budget.
                        name: name,
                        // Total budget amount.
                        amount: amount,
                        // Progress as a fraction of total.
                        progress: spending / amount,
                        // Timeline for the budget.
                        timeline: timeline,
                        // Color tag for the budget.
                        color: color,
                        onAllocate: (amount) {
                          // Function to allocate funds when triggered.
                          _allocateFunds(budgetId, amount, 'expense');
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Section for Savings Budgets (follows a similar structure to Expense Budgets).
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
                          : Colors.blue;

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

            // Button to navigate to the AddBudgetPage for adding new budgets.
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
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      "Add Budget",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BudgetItem widget for displaying individual budget details.
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
        title: Text(name),
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
            Text('Progress: \$${(progress * amount).toStringAsFixed(2)} of \$${amount.toStringAsFixed(2)}'),
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
                          Navigator.pop(context); // Close dialog
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
