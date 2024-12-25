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
      type: BottomNavigationBarType.fixed,
      backgroundColor:  Color(0xFF2832C2).withOpacity(0.5),
      selectedItemColor: Colors.white, // Color of the selected item
      unselectedItemColor: Color(0xFF281E5D), // Color of unselected items
      selectedFontSize: 16, // Font size for selected item
      unselectedFontSize: 14, // Font size for unselected items
      elevation: 0, // Elevation for the nav bar
    );
  }
}
