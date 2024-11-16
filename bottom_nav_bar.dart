import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyBottomNavigationBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Budgets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.green, // Background color of the nav bar
      selectedItemColor: Colors.black, // Color of the selected item
      unselectedItemColor: Colors.orange, // Color of unselected items
      selectedFontSize: 14.0, // Font size for selected item
      unselectedFontSize: 12.0, // Font size for unselected items
      elevation: 8, // Elevation for the nav bar
    );
  }
}
