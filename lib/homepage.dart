import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/Home.dart';
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
    Home(), // Placeholder for Home page content
    Transactions(),
    Budgets(),
    Profile()
  ];

  // Update selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        body: _pages[_selectedIndex], // Directly display the selected page
        bottomNavigationBar: MyBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
