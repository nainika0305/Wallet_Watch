import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/ChangeCurrency.dart';
import 'package:wallet_watch/CurrencyConversion.dart';
import 'package:wallet_watch/ExportReport.dart';
import 'package:wallet_watch/FAQs.dart';
import 'package:wallet_watch/Feedback.dart';
import 'package:wallet_watch/PageNotFound.dart';
import 'package:wallet_watch/Settings.dart';
import 'package:wallet_watch/TaxEstimationTool.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

void _signOut() async {
  await FirebaseAuth.instance.signOut();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Profile Button for Editing
            _buildProfileButton(context),

            // Spacer for spacing out the profile button from the rest
            SizedBox(height: 20.0),

            // List of buttons
            _buildButtonRow(
              'Settings',
              Colors.blueAccent,
              Colors.pinkAccent,
                  () {
                // Navigate to settings page
                    Navigator.pushNamed(context, '/settings');
              },
              alignment: Alignment.centerLeft,
            ),
            _buildButtonRow(
              'Feedback/Rate',
              Colors.pinkAccent,
              Colors.blueAccent,
                  () {
                // Navigate to feedback page
                    Navigator.pushNamed(context, '/feedback');
              },
              alignment: Alignment.centerRight,
            ),
            _buildButtonRow(
              'Change Currency',
              Colors.blueAccent,
              Colors.pinkAccent,
                  () {
                // Navigate to currency change page
                    Navigator.pushNamed(context, '/changeCurrency');
              },
              alignment: Alignment.centerLeft,
            ),
            _buildButtonRow(
              'Monthly CSV/Excel Export',
              Colors.pinkAccent,
              Colors.blueAccent,
                  () {
                // Navigate to export page
                    Navigator.pushNamed(context, '/report');
              },
              alignment: Alignment.centerRight,
            ),
            _buildButtonRow(
              'Log Out',
              Colors.blueAccent,
              Colors.pinkAccent,
                  () {
                _signOut(); // Sign out function
              },
              alignment: Alignment.centerLeft,
            ),
            _buildButtonRow(
              'Tax Estimation Tool',
              Colors.pinkAccent,
              Colors.blueAccent,
                  () {
                // Navigate to tax estimation page
                    Navigator.pushNamed(context, '/tax');
              },
              alignment: Alignment.centerRight,
            ),
            _buildButtonRow(
              'FAQs',
              Colors.blueAccent,
              Colors.pinkAccent,
                  () {
                // Navigate to FAQ page
                    Navigator.pushNamed(context, '/faqs');
              },
              alignment: Alignment.centerLeft,
            ),
            _buildButtonRow(
              'Currency Conversion',
              Colors.pinkAccent,
              Colors.blueAccent,
                  () {
                // Navigate to currency conversion page
                    Navigator.pushNamed(context, '/conversion');
              },
              alignment: Alignment.centerRight,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to profile edit page
        //Navigator.push(
        //context,
        //MaterialPageRoute(builder: (context) => ProfileEditPage()), // Replace with your profile edit page
        //);
      },
      child: Container(
        width: 400,
        height: 100.0, // Larger size
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.3), // Make the button semi-transparent
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align to opposite sides
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding for left side
              child: Text(
                user.displayName ?? 'Username', // Use 'Username' if displayName is null
                style: TextStyle(
                  fontSize: 24.0, // Adjust font size as needed
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // Padding for right side
              child: CircleAvatar(
                radius: 30.0, // Size of the avatar
                backgroundImage: NetworkImage(user.photoURL ?? 'default_image_url'), // Use default image URL if photoURL is null
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }




  // Helper function for alternating buttons on different lines
  Widget _buildButtonRow(
      String title,
      Color color1,
      Color color2,
      VoidCallback onTap, {
        Alignment alignment = Alignment.centerLeft,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 65.0,
            width: 360, // Make sure it takes the full width
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
