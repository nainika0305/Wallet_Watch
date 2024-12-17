import 'package:flutter/material.dart';
import 'package:wallet_watch/forgot_password.dart';
import 'package:wallet_watch/privacypolicy.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isDarkMode = false; // Dark mode flag
  String _selectedFont = 'Roboto'; // Default font
  double _fontSize = 16.0; // Default font size

  // List of available fonts
  List<String> _fonts = ['Roboto', 'Arial', 'Times New Roman', 'Courier'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customize Your Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 30),

            // Dark Mode Toggle
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkMode,
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.teal,
              ),
            ),

            // Font Size Slider
            ListTile(
              title: const Text('Font Size'),
              subtitle: Text('Current Font Size: ${_fontSize.toStringAsFixed(1)}'),
              trailing: SizedBox(
                width: 150,
                child: Slider(
                  min: 12,
                  max: 24,
                  value: _fontSize,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                  activeColor: Colors.teal,
                ),
              ),
            ),

            // Font Selection Dropdown
            ListTile(
              title: const Text('Font Family'),
              subtitle: Text('Selected Font: $_selectedFont'),
              trailing: SizedBox(
                width: 150,
                child: DropdownButton<String>(
                  value: _selectedFont,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFont = newValue!;
                    });
                  },
                  items: _fonts
                      .map((font) => DropdownMenuItem(
                    value: font,
                    child: Text(font),
                  ))
                      .toList(),
                ),
              ),
            ),

            // Privacy Policy Button
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsAndConditions()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Privacy Policy'),
            ),

            // Forgot Password Button
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[200],
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Forgot Password'),
            ),

            // Reset Settings Button
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isDarkMode = false;
                  _selectedFont = 'Roboto';
                  _fontSize = 16.0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Reset to Default Settings'),
            ),
          ],
        ),
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
    );
  }
}
