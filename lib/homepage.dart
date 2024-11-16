import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/Profile.dart';
import 'package:wallet_watch/Transactions.dart';
import 'package:wallet_watch/bottom_nav_bar.dart';
import 'package:wallet_watch/budgets.dart';
import 'package:wallet_watch/login_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0; // Keep track of the selected tab
  final user = FirebaseAuth.instance.currentUser!;

  // List of pages to display based on the selected tab
  final List<Widget> _pages = [
    Center(child: Text('Home Page Content')), // Placeholder for Home page content
    Transactions(),
    Profile(),
    Budgets(),
  ];

  // Update selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false, // Prevent back navigation
        child: Scaffold(
      appBar: AppBar(
        title: Text('welcome to homepage'),
      ),
      body: Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Hello! Signed in as ' + user.email!),
        const SizedBox(height: 20), // Space between text and button
        ElevatedButton(
          onPressed: _signOut,
          style: ElevatedButton.styleFrom(

          ),
          child: const Text('Sign Out'),
        ),
        const SizedBox(height: 20), // Space for visual clarity
        Expanded(child: _pages[_selectedIndex]), // Display the selected page
      ],
    ),
    ),
      bottomNavigationBar: MyBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    ),
    );
  }
}