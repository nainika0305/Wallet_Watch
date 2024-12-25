import 'package:flutter/material.dart';

class DarkModeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify all listeners when state changes
  }

  // Optionally, you can provide a method to set dark mode explicitly
  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
