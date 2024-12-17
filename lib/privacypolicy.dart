import 'package:flutter/material.dart';
import 'package:wallet_watch/wrapper.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  _TermsAndConditions createState() => _TermsAndConditions();
}

class _TermsAndConditions extends State<TermsAndConditions> {
  bool _isAccepted = false; // Track if terms are accepted

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please read and accept the terms and conditions to proceed.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),

            // Scrollable Privacy Policy Text
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Put the privacy policy and all the terms and conditions here. '
                        'You can list the policies regarding data usage, privacy, security, etc.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Checkbox with text
            Row(
              children: [
                Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.teal, // Color of checkbox when not selected
                  ),
                  child: Checkbox(
                    value: _isAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAccepted = value ?? false;
                      });
                    },
                    activeColor: Colors.teal,
                    checkColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAccepted = !_isAccepted;
                      });
                    },
                    child: const Text(
                      'I accept the terms and conditions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Next Button
            ElevatedButton(
              onPressed: _isAccepted
                  ? () {
                Navigator.pushNamed(context, '/wrapper');
              }
                  : null, // Button disabled until accepted
              child: const Text('Next'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 16), // Text color
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
