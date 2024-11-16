import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.all(160),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile page'),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello! Signed in as ${user.email!}'),
                const SizedBox(height: 20), // Space between text and button
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(),
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 20), // Space for visual clarity
              ],
            ),
          ],
        ),
      ),
    );
  }
}
