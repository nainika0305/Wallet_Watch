import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser!;
  String displayName = 'Loading...'; // Placeholder while data is being fetched
  String initials = 'NN'; // Default initials if data is not fetched

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        setState(() {
          displayName = '${data['first_name']} ${data['last_name']}';
          initials = _getInitials(displayName); // Set initials after fetching name
        });
      } else {
        setState(() {
          displayName = 'No Name Found';
          initials = 'NN'; // Default initials if no name found
        });
      }
    } catch (e) {
      setState(() {
        displayName = 'Error fetching name';
        initials = 'EN'; // Default initials for error
      });
    }
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String firstInitial = nameParts.isNotEmpty ? nameParts[0][0] : '';
    String secondInitial = nameParts.length > 1 ? nameParts[1][0] : '';
    return (firstInitial + secondInitial).toUpperCase();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Enhanced Profile Section
            _buildProfileCard(context),

            const SizedBox(height: 30.0),

            // Alternating Buttons
            _buildButtonRow(
              title: 'Settings',
              colors: [Colors.teal, Colors.greenAccent],
              icon: Icons.settings,
              alignment: Alignment.centerLeft,
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            _buildButtonRow(
              title: 'Feedback/Rate',
              colors: [Colors.purpleAccent, Colors.blue],
              icon: Icons.feedback,
              alignment: Alignment.centerRight,
              onTap: () {
                Navigator.pushNamed(context, '/feedback');
              },
            ),

            _buildButtonRow(
              title: 'Log Out',
              colors: [Colors.red, Colors.orange],
              icon: Icons.logout,
              alignment: Alignment.centerLeft,
              onTap: () {
                _signOut();
              },
            ),
            _buildButtonRow(
              title: 'Tax Estimation Tool',
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              icon: Icons.calculate,
              alignment: Alignment.centerRight,
              onTap: () {
                Navigator.pushNamed(context, '/tax');
              },
            ),
            _buildButtonRow(
              title: 'FAQs',
              colors: [Colors.green, Colors.lightGreenAccent],
              icon: Icons.question_answer,
              alignment: Alignment.centerLeft,
              onTap: () {
                Navigator.pushNamed(context, '/faqs');
              },
            ),
            _buildButtonRow(
              title: 'Currency Conversion',
              colors: [Colors.indigo, Colors.cyan],
              icon: Icons.swap_horiz,
              alignment: Alignment.centerRight,
              onTap: () {
                Navigator.pushNamed(context, '/conversion');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Profile Card
  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User Avatar with initials
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.teal, // Set background color for contrast
              child: Text(
                initials, // Display the initials
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ensure the initials are visible
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Username Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  user.email ?? 'Email not available',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Button Row
  Widget _buildButtonRow({
    required String title,
    required List<Color> colors,
    required IconData icon,
    required VoidCallback onTap,
    required Alignment alignment,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Align(
        alignment: alignment,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 70.0,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(icon, color: Colors.white, size: 28.0),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
