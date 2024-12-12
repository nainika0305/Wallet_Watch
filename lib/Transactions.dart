import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/AddTransaction.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<Transactions> {

  final CollectionReference _transactions =
  FirebaseFirestore.instance.collection('transactions');


  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Expense',
    'Income',
    'Category',
    'Mode',
    'Ascending Date',
    'Amount',
    'Loans',
    'Investments'
        'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),


      // now read n display the transactions
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // read n display
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching transactions.'));
                  }
                  final transactions = snapshot.data?.docs ?? [];
                  if (transactions.isEmpty) {
                    return Center(child: Text('No transactions found.'));
                  }


                  // what all we want to display?  check
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final data = transaction.data() as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(data['title'] ?? 'No Title'),
                          subtitle: Text(
                              'Category: ${data['category'] ?? 'Unknown'} | Amount: \$${data['amount'] ?? 0}'),
                          trailing: Text(data['date'] ?? 'No Date'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),


            // buttons now
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddTransactionPage()),
                    );
                  },

                  icon: Icon(Icons.add),
                  label: Text('Add Transaction'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Manage Subscriptions Page
                  },
                  child: Text('Manage Subscriptions'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Insurance Page
                  },
                  child: Text('Insurance'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Loans Page
                  },
                  child: Text('Loans'),
                ),
              ],
            ),
          ],
        ),
      ),



      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Transaction page index
        onTap: (index) {
          // Navigate to the respective page
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/transactions');
          if (index == 2) Navigator.pushNamed(context, '/budgets');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Budgets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }



  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Filter'),
          content: SingleChildScrollView(
            child: Column(
              children: _filters.map((filter) {
                return RadioListTile(
                  title: Text(filter),
                  value: filter,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Method to get filtered transactions based on selected filter
  Stream<QuerySnapshot> _getFilteredTransactions() {
    if (_selectedFilter == 'All') {
      return _transactions.snapshots(); // No filter, return all transactions
    } else if (_selectedFilter == 'Category') {
      return _transactions.where('category', isEqualTo: 'YourCategory').snapshots();
    } else if (_selectedFilter == 'Income' || _selectedFilter == 'Expense') {
      return _transactions.where('type', isEqualTo: _selectedFilter).snapshots();
    } else if (_selectedFilter == 'Ascending Date') {
      return _transactions.orderBy('date', descending: false).snapshots();
    } else if (_selectedFilter == 'Amount') {
      return _transactions.orderBy('amount').snapshots();
    } else {
      // You can add more filters as needed
      return _transactions.snapshots(); // Default if no specific filter matched
    }
  }
}
