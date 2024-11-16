import 'package:flutter/material.dart';
import 'package:wallet_watch/AddTransaction.dart';
import 'package:wallet_watch/Tips.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/bottom_nav_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display total money
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Total Money Available",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "₹5000.00", // Replace with dynamic value
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Graph Options (example: total money, expense, income)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGraphOption(context, "Total Money", Colors.blue),
                _buildGraphOption(context, "Expense", Colors.red),
                _buildGraphOption(context, "Income", Colors.green),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Tips and Tricks'),
                      ),
                      body: const Tips(), // Render the Tips page
                      bottomNavigationBar: MyBottomNavigationBar(
                        currentIndex: 0, // Lock the bottom nav bar on Home
                        onTap: (index) {
                          if (index == 0) {
                            Navigator.pop(context); // Go back to Home
                          }
                        },
                      ),
                    ),
                  ),
                );
              }, //onpressed
              child: const Text('Tips'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Add transaction'),
                      ),
                      body: const Addtransaction(), // Render the Tips page
                      bottomNavigationBar: MyBottomNavigationBar(
                        currentIndex: 0, // Lock the bottom nav bar on Home
                        onTap: (index) {
                          if (index == 0) {
                            Navigator.pop(context); // Go back to Home
                          }
                        },
                      ),
                    ),
                  ),
                );
              }, //onpressed
              child: const Text('Add Transactions'),
            ),
          ],
        ),
      ),
    );
  }

  // Graph Option Widget
  Widget _buildGraphOption(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle graph selection logic here
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$title Graph Selected")));
      },
      child: Column(
        children: [
          Icon(Icons.pie_chart, size: 40, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}





/*
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Homepage'),
            automaticallyImplyLeading: false
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ElevatedButton(
              onPressed: () {
                Navigator.push(context,MaterialPageRoute(
                builder: (context) => Scaffold(
                appBar: AppBar(
                    title: Text('Tips and Tricks'),
                    ),
                    body: Tips(), // Render the Tips page
                    bottomNavigationBar: MyBottomNavigationBar(
                    currentIndex: 0, // Lock the bottom nav bar on Home
                    onTap: (index) {
                      if (index == 0) {
                      Navigator.pop(context); // Go back to Home
                    }
                 },
                  ),
                ),
                ),
                );
                }, //onpressed
             child: Text('Tips'),
              ),

                SizedBox(height: 20),


                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text('Add transaction'),
                        ),
                        body: Addtransaction(), // Render the Tips page
                        bottomNavigationBar: MyBottomNavigationBar(
                          currentIndex: 0, // Lock the bottom nav bar on Home
                          onTap: (index) {
                            if (index == 0) {
                              Navigator.pop(context); // Go back to Home
                            }
                          },
                        ),
                      ),
                    ),
                    );
                  }, //onpressed
                  child: Text('Add Transactions'),
                ),
         ],
         ),
        ),
    );
  }
}
*/