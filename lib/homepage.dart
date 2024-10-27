import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wallet_watch/login_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello ! signed in as  ' + user.email!),
            MaterialButton(onPressed: (){
              FirebaseAuth.instance.signOut();
            },
              color: Colors.deepPurple[200],
              child: Text('sign out'),
            )
          ]
        )
      )
          
    );

  }
}
