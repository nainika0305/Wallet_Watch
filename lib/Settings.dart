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
        backgroundColor: _isDarkMode
            ? const Color(0xFF2C2C2C) // Dark grey for dark mode
            : const Color(0xFFCDB4DB), // Soft lavender tone for light mode
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDarkMode
                ? [Colors.black87, Colors.grey] // Dark gradient for dark mode
                : [Color(0xFFBDE0FE), Color(0xFFFFC8DD)], // Sky blue to pink gradient for light mode
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customize Your Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Dark Mode Toggle
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                secondary: Icon(
                  _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: _isDarkMode ? Colors.white : Color(0xFFFFAFCC),
                ),
              ),
              const SizedBox(height: 10),

              // Font Size Slider
              ListTile(
                title: Text(
                  'Font Size',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Current Font Size: ${_fontSize.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
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
                    activeColor: _isDarkMode ? Colors.white : const Color(0xFFBDE0FE),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Font Selection Dropdown
              ListTile(
                title: Text(
                  'Font Family',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Selected Font: $_selectedFont',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
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
                      child: Text(
                        font,
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Buttons Section
              Center(
                child: Column(
                  children: [
                    _buildButton(
                      label: 'Privacy Policy',
                      color: _isDarkMode
                          ? const Color(0xFF2C2C2C) // Dark grey for dark mode
                          : const Color(0xFFCDB4DB), // Soft lavender tone for light mode
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditions(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: 'Forgot Password',
                      color: _isDarkMode
                          ? const Color(0xFF2C2C2C) // Dark grey for dark mode
                          : const Color(0xFFFFC8DD), // Light pinkish shade for light mode
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildButton(
                      label: 'Reset to Default Settings',
                      color: _isDarkMode
                          ? const Color(0xFF2C2C2C) // Dark grey for dark mode
                          : const Color(0xFFFFAFCC), // Vibrant rose pink for light mode
                      onPressed: () {
                        setState(() {
                          _isDarkMode = false;
                          _selectedFont = 'Roboto';
                          _fontSize = 16.0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
